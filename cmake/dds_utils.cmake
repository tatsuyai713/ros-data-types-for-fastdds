macro(COMPILE_IDL _idl_file)
    message(STATUS "Running IDL Compiler on ${_idl_file}")
    get_filename_component(_idl ${_idl_file} NAME_WE)
    set(_idl_srcs_var ${_idl}_SRCS)
    set(_idl_impl_srcs_var ${_idl}_IMPL_SRCS)
    get_filename_component(_idl_dir "${_idl_file}" PATH)
    get_filename_component(_idl_parent_dir "${_idl_dir}" DIRECTORY)
    get_filename_component(_idl_grand_parent_dir "${_idl_parent_dir}" DIRECTORY)
    get_filename_component(_idl_parent_dir_name "${_idl_dir}" NAME)
    get_filename_component(_idl_grand_parent_dir_name "${_idl_parent_dir}" NAME)
    set(_workingdir ${CMAKE_CURRENT_BINARY_DIR}/${_idl_grand_parent_dir_name}/${_idl_parent_dir_name})
	configure_file(${_idl_file} ${_workingdir}/${_idl}.idl COPYONLY)
    message(STATUS "Doing initial compile for ${_idl_file}")
    execute_process(COMMAND fastddsgen ${_idl}.idl  -I ${_idl_dir} -I ${_idl_grand_parent_dir} -d ${_workingdir} -typeros2 -replace -cs
                    WORKING_DIRECTORY ${_workingdir}
                    INPUT_FILE ${_idl}.idl
                    )
endmacro(COMPILE_IDL)

macro(COMPILE_IDL_FILES)
    set(idl_srcs)
    foreach(idl ${ARGN})
        COMPILE_IDL(${idl})
    endforeach(idl)
endmacro(COMPILE_IDL_FILES)

