class HealthMonitor:

    def evaluate(self,

                 battery,

                 temperature,

                 altitude,

                 velocity):

        faults = []

        if battery < 22:

            faults.append("LOW BATTERY")

        if temperature > 80:

            faults.append("HIGH TEMPERATURE")

        if altitude < 0:

            faults.append("INVALID ALTITUDE")

        if velocity < 0:

            faults.append("INVALID VELOCITY")

        if len(faults) == 0:

            return "HEALTHY"

        return ", ".join(faults)