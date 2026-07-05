from pathlib import Path

import numpy as np
import numpy.typing as npt
from rich.console import Console

from climate_attitudes.cli.common import BaseCommand
from ising import Ising, SymmetricIsing

np.set_printoptions(linewidth=200)

console = Console()


def calc_activation_prob[T: Ising](
    cls: type[T],
    prevs: npt.NDArray[np.int64],
    h: npt.NDArray[np.float64],
    j: npt.NDArray[np.float64],
) -> npt.NDArray[np.float64]:
    adj = np.ones((h.size, h.size), dtype=np.int64)
    h_eff = cls.parallel_glauber_theta_batch(
        prevs,
        np.ones(prevs.shape[0], dtype=np.float64),
        h,
        j,
        adj,
    )
    return np.exp(h_eff) / (2 * np.cosh(h_eff))


def calc_activation_probs[T: Ising](
    cls: type[T],
    params: npt.NDArray[np.float64],
    measurements: npt.NDArray[np.int64],
    measure_time: int | None,
    intervention_delta: float,
) -> npt.NDArray[np.float64]:
    R, M, Tplus1, N, _ = measurements.shape
    T = Tplus1 - 1

    timesteps = np.arange(T)
    if measure_time is not None:
        timesteps = np.array([measure_time])

    # (repeat, intervene idx, timestep, individual, prob spin idx)
    p = np.empty((R, M, T, N, N), dtype=np.float64)
    for r in range(R):
        h = params[r][:N]
        j = params[r][N:].reshape((N, N))
        for intervene_idx in range(N):
            h_int = h.copy()
            h_int[intervene_idx] += intervention_delta
            for t_i, t in enumerate(timesteps):
                # NOTE: Take prev = measurement at t rather than t-1 bc we include
                # second-to-last survey response in measurements
                this_p = calc_activation_prob(
                    cls,
                    measurements[r, :, t, intervene_idx],
                    h_int,
                    j,
                )

                p[
                    r,
                    :,
                    t_i,
                    intervene_idx,
                ] = this_p

    # (repeat, individual, timestep, intervene idx, prob spin idx)
    if measure_time is not None:
        p = p[:, :, 0]

    return p


class CalculateActivationProbabilityCommand(BaseCommand):
    simulation_results: Path
    intervention_delta: float
    measure_time: int | None = None
    output: Path

    def cli_cmd(self) -> None:
        results = np.load(self.simulation_results)
        match str(results["model_type"]):
            case "ising":
                cls = Ising
            case "sym_ising":
                cls = SymmetricIsing
            case m:
                raise ValueError(
                    f"Unknown model type '{m}' found in simulation results file."
                )

        # S0 is the second-to-last survey measurement, sets probability for the last
        S0 = results["Y"][:, :, -2:-1]
        S = results["measurements"]

        # Concatenate along the time dimension (axis=2)
        R, M, _, N, _ = S.shape
        S0_expanded = np.broadcast_to(S0[..., np.newaxis, :], (R, M, 1, N, N))
        S = np.concatenate([S0_expanded, S], axis=2)

        p = calc_activation_probs(
            cls, results["params"], S, self.measure_time, self.intervention_delta
        )

        np.savez_compressed(self.output, p=p)
