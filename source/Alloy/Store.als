module Store
open util/ordering [TypeStore] as TypeStoreOrder

//-------------------------------------
sig Type_name {}
sig Type_version {}
sig Type { name_version: Type_name->Type_version }

fact "Types have a unique name and version"
{all type: Type | type.name_version not in {Type-type}.name_version and #type.name_version = 1 }

sig TypeStore { types: set Type }


//------------------------------------------------------------------
pred init [store: TypeStore]
{
	store.types = none
}

pred create_type [type: Type, store, store' : TypeStore]
{
	store'.types = store.types + type
}

pred delete_type [type: Type, store, store' : TypeStore]
{
	store'.types = store.types - type
}

fact Trace
{
	init[first]
	all store: TypeStore | let store' = store.next |
		some type: Type | 
			create_type [type, store, store'] or delete_type [type, store, store']			
}

assert delUndoesAdd {
	all store, store', store'' : TypeStore, type: Type |
		create_type [type, store, store'] and delete_type [type, store', store'']	
		implies
		store.types = store''.types
}

check delUndoesAdd for 5
//------------------------------------------------------------------

pred show [] {}
run show for 5 TypeStore, 5 Type, 5 Type_name, 5 Type_version

