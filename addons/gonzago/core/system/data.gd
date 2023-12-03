@tool
class_name GonzagoData
extends Resource
## Base class for adressable Gonzago data.
##
## This is a data container that is adressable and
## can have components and extensions.
## Like systems, rooms, characters, items, music, etc.

## The general data group this resource gets added to.
const GONZAGO_DATA_GROUP := &"gonzago.data"

var _extensions: Array[GonzagoDataExtension] = []
var _components: Array[GonzagoDataComponent] = []
