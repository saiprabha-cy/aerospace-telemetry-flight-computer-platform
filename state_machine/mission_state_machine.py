from state_machine.mission_states import MissionState


class MissionStateMachine:

    def __init__(self):
        self.current_state = MissionState.INITIALIZATION

    def transition_to(self, new_state):

        print(
            f"\nSTATE CHANGE : "
            f"{self.current_state.value}"
            f" --> "
            f"{new_state.value}"
        )

        self.current_state = new_state

    def get_state(self):
        return self.current_state