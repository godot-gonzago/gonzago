@tool
class_name GonzagoSystem
extends Node


## Base class for Gonzago systems.
## Systems can be loaded or unloaded based on
## application state or feature flags.
## Systems are kept alive as long as the
## instantiating application state or a substate
## thereof is active.
