
Triggers.getLastRunUsage's original intended use and it's actual use differ.  It is being used as though it returns the last time that triggers were updated for that profile_name and interface combo. It's intended meaning is to be used to return the percent that a last initiated a trigger to be run at, to help determine if a trigger has already been run once in this billing cycle or not.
