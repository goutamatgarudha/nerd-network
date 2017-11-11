# Makefile

# LIBNERDNETWORK - The NERDDNTWORK Library
# Copyright (C) 2017 Goutam Hegde
#
# Makefile
# (C) 2017 Goutam Hegde <goutam@garudha.org>
#
# This library is free software: you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.  If not, see
# <http://www.gnu.org/licenses/>.

#------------------- Variables defining user-defined configurations ----------#


ifndef INCLUDES
	INCLUDES = -Iinclude/
endif

ifndef LIBS
	LIB_NAMES = -lservo.a
endif

ifndef CXX_STD 
	CXX_STD = gnu++11
endif

ifndef C_STD 
	C_STD = gnu11
endif

#--------------------- Function definations for various tasks -----------------#

## @brief This function compilesi and assembles but doesn't link the list of
##		   given source files. i.e.: Builds the object filesi with the given
##		   compiler.
## eg: compile_list (src_files, obj_files, compiler).
## @param src_files List of source files which has to be compiled.
## @param obj_files List of target object files. 
## @param Command which has to be executed in the loop. 
##		  eg: build_c_obj,  build_cxx_obj, build_ino_obj.
ifndef build_objs
define build_objs

	$(eval len_list = $(words $(1)) )
	$(eval m_range = $(shell seq 1 $(len_list)) )
	
	$(foreach index, $(m_range),\
			  $(call $(3), $(word $(index), $(1)),	\
						   $(word $(index), $(2)) ); \
	 )
endef
endif

## @brief This function compiles and assembles but doesn't link the given 
##		  *.c src file.
## eg: build_c_objs (src_c_file, build_c_obj). 
## @param src_c_file *.c src file.
## @param build_c_obj *.c.o target object.
ifndef build_c_obj
	build_c_obj = $(CC) $(CFLAGS) $(CPPFLAGS) $(CCFLAGS) -o $(2) $(1) 
endif

## @brief This function compiles and assembles but doesn't link the given 
##		  *.cxx *.cpp src file.
## eg: build_cxx_obj (src_cxx_file, build_cxx_obj). 
## @param src_cxx_files *.cxx or *.cpp src file.
## @param build_c_objs *.cxx.o or *.cpp.o target object.
ifndef build_cxx_obj
	build_cxx_obj = $(CXX) $(CFLAGS) $(CPPFLAGS) $(CXXfLAGS) -o $(2) $(1)
endif

## @brief This function lists out sub directories under given directory.
## eg: sub_dirs = get_sub_dirs (src_dir).
## @param src_dir Directory in which the sub directories have to be listed.
## @return Lists the sub directories under given directory.
ifndef get_sub_dirs
	get_sub_dirs = $(sort $(dir $(wildcard $(1)/*/)))
endif

## @brief This function list out all the files with given extension inside the
##		   given list of directories.
## eg: x_files = get_x_files (dirs, *.x);
## @param dirs List of directories in which the the files wiht *.x ext has to 
##			   be found.
## @param *.x The file extension with which the files have to be found.
##			   eg: *.c.
## @return List of files with *.x extension under dirs. 
ifndef get_x_files
	get_x_files = $(foreach dir, $(1), $(wildcard $(join $(dir)/, $(2) )) )
endif

#--------------- Variables defining compilers and other tools -----------------#
# c compiler
ifndef CC
	CC 	= gcc
endif 

# cxx compiler
ifndef CXX
	CXX = g++
endif 

#--------- Variables defining unix commands for basic operations --------------#
#------------------------------- like delete, move etc. -----------------------#

ifndef MKDIR_CMD
	MKDIR_CMD = mkdir -p
endif

ifndef REMOVE_CMD
	REMOVE_CMD = rm -rf
endif

ifndef MOVE
	MOVE = mv
endif

ifndef COPY
	COPY = cp -r
endif

#------------ Variables defining compiler and pre-processor flags ------------#

ifndef CPPFLAGS
	CPPFLAGS =  $(INCLUDES)
endif 

ifndef CFLAGS
	CFLAGS = -c -fPIC 
endif

ifndef CXXFLAGS
	CXXFLAGS = 
endif 

ifndef CCFLAGS
	CCFLAGS = 
endif



#------------------ Variables defining the SRC dirs and SRC files -------------#

ifndef SRC_DIR
	SRC_DIR = src
endif

# Listing all subdirs under LOCAL_SRC_DIR
ifndef SRC_SUBDIRS
	SRC_SUBDIRS = $(call get_sub_dirs, $(SRC_DIR))
endif 

# Listing all *.c files under LOCAL_SRC_SUBDIRS
ifndef SRC_C_FILES
	SRC_C_FILES = $(call get_x_files, $(SRC_SUBDIRS), *.c)
endif

# Listing all *.cpp files under LOCAL_SRC_SUBDIRS
ifndef SRC_CXX_FILES
	SRC_CXX_FILES = $(call get_x_files, $(SRC_SUBDIRS), *.cpp)
endif

#-------------- Variables defining the BUILD dirs and BUILD FILES -------------#

ifndef BUILD_DIR
	BUILD_DIR = build
endif

# Listing all the build subdirs for local sources.
ifndef BUILD_SUBDIRS
	BUILD_SUBDIRS = $(SRC_SUBDIRS:$(SRC_DIR)/%=$(BUILD_DIR)/%)
endif

# Listing all the local c object files.
ifndef BUILD_C_OBJS
	BUILD_C_OBJS = $(SRC_C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.c.o)
endif

# Listing all the local cpp object files.
ifndef BUILD_CXX_OBJS
	BUILD_CXX_OBJS = $(SRC_CXX_FILES:$(SRC_DIR)/%.cpp=$(BUILD_DIR)/%.cpp.o)
endif

#--------------------------- Set of Makefile tasks ----------------------------#

print:
	@echo $(BUILD_SUBDIRS)

all: clean build-dir-structure build-objs 
	@echo "Project built under $(BUILD_DIR)."

build-objs: build_c_objs build_cxx_objs $(LOCAL_BUILD_INO_OBJ)
	@echo "Built all objects."

build_c_objs: $(SRC_C_FILES)
	$(call build_objs, $^, $(BUILD_C_OBJS), build_c_obj)
	@echo "Built all C objects."

build_cxx_objs: $(SRC_CXX_FILES)
	$(call build_objs, $^, $(BUILD_CXX_OBJS), build_cxx_obj)
	@echo "Built all CXX objects."

build-dir-structure:
	$(MKDIR_CMD) $(BUILD_SUBDIRS)
	@echo "Build directory structure createed."

clean:
	$(REMOVE_CMD) $(BUILD_DIR)
	@echo "Project cleaned."

.PHONY: build-dir-structure clean print
