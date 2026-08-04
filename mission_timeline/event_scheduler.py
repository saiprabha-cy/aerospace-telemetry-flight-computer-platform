"""
event_scheduler.py

Provides scheduled mission events.
"""

from mission_timeline.mission_events import MISSION_EVENTS


class EventScheduler:

    def get_event(self, mission_time):

        return MISSION_EVENTS.get(mission_time, None)