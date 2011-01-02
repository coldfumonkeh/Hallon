#include "common.h"

#define LINKPTR_OF(obj) *Data_Fetch_Struct(obj, sp_link*)

/*
  Prototypes.
*/
static void cLink_s_free(sp_link**);

/*
  Allocate space for an sp_link* and attach it.
*/
static VALUE cLink_s_alloc(VALUE klass)
{
  return Data_Build_Struct(klass, sp_link*, NULL, cLink_s_free);
}

/*
  Release an allocated sp_link*, but only if it’s not a NULL-pointer (handled by xfree).
*/
static void cLink_s_free(sp_link **link_ptr)
{
  xfree(link_ptr);
}

/*
  call-seq: initialize(spotify_uri)
  
  Create a Link object from a given Spotify URI.
  
  @param [#to_s] spotify_uri
  @raise [ArgumentError] if the link could not be parsed
*/
static VALUE cLink_initialize(VALUE self, VALUE str)
{
  char *link = StringValueCStr(str);
  sp_link *link_ptr = LINKPTR_OF(self) = sp_link_create_from_string(link);
  
  if ( ! link_ptr)
  {
    rb_raise(rb_eArgError, "“%s” is not a valid Spotify URI", link);
  }
  
  return self;
}

/*
  Retrieve the Spotify URI this Link represents.
  
  @param [Fixnum] maxlength maximum string length (in bytes) to return (default: 2048)
  @return [String]
*/
static VALUE cLink_to_str(int argc, VALUE *argv, VALUE self)
{
  VALUE maxlength = Qnil;
  int length = 0;
  int maxsize = 0;
  char *buffer = NULL;
  VALUE str = Qnil;
  
  rb_scan_args(argc, argv, "01", &maxlength);
  maxsize = NIL_P(maxlength) ? 2048 : FIX2INT(maxlength);
  
  /* retrieve string length */
  length = sp_link_as_string(LINKPTR_OF(self), buffer, 0);
  length = MIN(length + 1, maxsize + 1); // careful, both arguments evaluated twice
  
  /* alloc memory for string and retrieve it */
  buffer = ALLOC_N(char, length);
  sp_link_as_string(LINKPTR_OF(self), buffer, length);
  str = rb_str_new2(buffer);
  xfree(buffer);
  return str;
}

void Init_Link(void)
{
  VALUE cLink = rb_define_class_under(hn_mHallon, "Link", rb_cObject);
  rb_define_alloc_func(cLink, cLink_s_alloc);
  rb_define_method(cLink, "initialize", cLink_initialize, 1);
  rb_define_method(cLink, "to_str", cLink_to_str, -1);
}