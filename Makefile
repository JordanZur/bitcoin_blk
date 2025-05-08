# Compiler and flags
CXX = g++                             # Use the C++ compiler
CXXFLAGS = -Wall -std=c++17 -fPIC     # Enable warnings, C++17, position-independent code (for .so)
IDIR = -I.                            # Include path: current directory
LDIR = build                          # Directory for library output
ODIR ?= build                         # Output directory for all compiled files (can be overridden externally)


# Name of the shared library
LIB = programs                        # The library will be named libprograms.so
LIBPATH = $(ODIR)/lib$(LIB).so       # Full path to the shared library file

# Source files used to create the shared library
LIB_SRCS := programs_lib.cpp

# Object file output path for the shared lib (e.g., build/programs_lib.o)
LIB_OBJS := $(addprefix $(ODIR)/, $(patsubst %.cpp,%.o,$(LIB_SRCS)))

# Main application source files (excluding library code)
SRCS := bitcoin_shell.cpp printdb.cpp block_finder.cpp db_to_csv.cpp refresh_db.cpp

# Output object files for each app (e.g., build/bitcoin_shell.o, etc.)
OBJS := $(addprefix $(ODIR)/, $(patsubst %.cpp,%.o,$(SRCS)))

# Output executable filenames
TARGETS := $(patsubst %.cpp,%.out,$(SRCS))
BINARIES := $(addprefix $(ODIR)/, $(TARGETS))

# Default build target (when running just `make`)
# It builds the shared library and all program binaries
all: $(LIBPATH) $(BINARIES)

# Rule to build the shared library from programs_lib.cpp
$(LIBPATH): $(LIB_SRCS)
	mkdir -p $(ODIR)                           # Ensure build directory exists
	$(CXX) -shared -o $@ $^ $(CXXFLAGS)        # Compile to .so file using -shared

# Rule to compile any .cpp file into a .o object file
# $< is the source file (%.cpp), $@ is the target (build/%.o)
$(ODIR)/%.o: %.cpp
	mkdir -p $(ODIR)                           # Ensure build directory exists
	$(CXX) $(CXXFLAGS) $(IDIR) -c -o $@ $<     # Compile source to object file

# Rule to compile each main program and link with the shared library
# $< is the .cpp file, $@ is the .out file
$(ODIR)/%.out: %.cpp $(LIBPATH)
	mkdir -p $(ODIR)                                           # Ensure build directory exists
	$(CXX) $(CXXFLAGS) $(IDIR) -o $@ $< -L$(ODIR) -l$(LIB) $(OS_LIBS)  # Compile + link with libprograms.so

# Shortcut target: builds the main CLI interactive shell
# Allows you to run: make myprog
myprog: $(ODIR)/bitcoin_shell.out

# Cleanup rule: deletes the build directory and all compiled output
clean:
	rm -rf $(ODIR)

