class GroundStation:

    def __init__(self):

        self.total_packets = 0

        self.healthy_packets = 0

        self.warning_packets = 0

    def update(self, status):

        self.total_packets += 1

        if status == "HEALTHY":

            self.healthy_packets += 1

        else:

            self.warning_packets += 1

    def summary(self):

        return {

            "Total": self.total_packets,

            "Healthy": self.healthy_packets,

            "Warning": self.warning_packets

        }