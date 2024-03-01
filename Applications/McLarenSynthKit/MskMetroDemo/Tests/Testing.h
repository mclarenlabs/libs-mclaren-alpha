/*
 * Simplified Testing Framework.
 *
 * (GNUmakefiles included Testing.h no longer works with ARC)
 *
 * McLaren Labs 2024
 */

static int testIndentation = 8;

static inline void testIndent(void) {
  unsigned i = testIndentation;
  while (i-- > 0) {
    fprintf(stderr, " ");
  }
}

static void pass(int passed, const char *format, ...) {
  va_list args;
  va_start(args, format);

  // # Set colors
  // GREEN=`tput setaf 2`
  // RED=`tput setaf 2`
  // NC=`tput sgr0` # No Color

#if 1
  // if Terminal supports ASCI escapes
  static char *GREEN = "\e[32m";
  static char *RED = "\e[31m";
  static char *NC = "\e[0m";
#else    
  static char *GREEN = "";
  static char *RED = "";
  static char *NC = "";
#endif

  if (passed) {
    fprintf(stderr, "%s***PASSED***%s test:    ", GREEN, NC);
  }
  else {
    fprintf(stderr, "%s***FAILED***%s test:    ", RED, NC);
  }

  testIndent();
  vfprintf(stderr, format, args);
  fprintf(stderr, "\n");
  va_end(args);
}
  

    
  
