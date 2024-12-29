@tool
class_name GonzagoApp
extends Node


## Main entry point of the application.


# AppStatesGraph
# +--------------+
# |  BootSplash  | Initialize
# +--------------+
# +--------------+
# | StartScreen  | Input gathering
# +--------------+
# +--------------++--------------+
# |   MainMenu   ||  SubMenu     | No transitions horizontally? Live in same scene
# +--------------++--------------+
# +--------------+
# |GameplayState |
# +--------------+
#      +--------------++-------------++--------------+
#      | Level01      ||  Level02    || GameplayMenu | Loading Ssreen On Level Load
#      +--------------++-------------++--------------+
#      +--------------++--------------++--------------+
#      |  PauseMenu   ||   SubMenu    ||   SubMenu    |
#      +--------------++--------------++--------------+
# +--------------+
# |   Credits    |
# +--------------+
