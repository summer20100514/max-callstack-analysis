# max-callstack-analysis
an easy to use max stack usage analysis script written in Perl, improved version of avstack.pl.
origin version written by Daniel Beer ##dlbeer@gmail.com https://dlbeer.co.nz/downloads/avstack.pl

# sample output

  Func                                           Cost    Frame   Height
------------------------------------------------------------------------
> pb_dec_submessage                               344       40        9
> pb_decode_delimited                             336       32        9
> pb_decode_delimited_noinit                      320       32        8
  pb_decode                                       304       16        8
> pb_decode_nullterminated                        304        0        9
  pb_decode_noinit                                288      104        7
  decode_field                                    184       80        6
R pb_release_single_field                         104       56        4
  initialize_pointer_field.isra.0                 104       16        5
R pb_message_set_to_defaults                       88       32        4
> pb_dec_svarint                                   88       24        4
> pb_dec_fixed_length_bytes                        72       32        4
  pb_decode_tag                                    72       32        3
> pb_dec_varint                                    72       32        3
  pb_make_string_substream                         64       24        4
  pb_decode_svarint                                64       24        3
> pb_dec_string                                    64       24        4
> pb_dec_uvarint                                   64       24        3
> pb_dec_bytes                                     64       24        4
  pb_field_set_to_default                          56       40        3
> pb_decode_bool                                   56        0        5
  pb_dec_bool                                      56       16        4
  pb_skip_field                                    56       16        4
  pb_decode_fixed32                                48       16        2
  pb_decode_fixed64                                48       16        2
> pb_dec_fixed64                                   48        0        3
  pb_release                                       48       32        3
  pb_close_string_substream                        48       16        2
> pb_dec_fixed32                                   48        0        3
  pb_decode_varint32                               40        0        3
  pb_decode_varint                                 40       32        2
  pb_decode_varint32_eof                           40       32        2
  pb_field_iter_find                               32       16        3
R pb_read                                          32       32        1
  iter_from_extension                              16       16        2
  pb_field_iter_next                               16       16        2
  allocate_field                                   16       16        1
> pb_istream_from_buffer                            8        8        1
  pb_readbyte                                       8        8        1
> buf_read                                          8        8        1
  pb_field_iter_begin                               0        0        1
> INTERRUPT                                         0        0        1


## Chain from pb_dec_submessage, Cost (344)
------------------------------------------------------------------------
  >pb_dec_submessage (40)
      >pb_decode (16)
          >pb_decode_noinit (104)
              >decode_field (80)
                  >pb_release_single_field (56)
                      >pb_release (32)
                          >pb_field_iter_next (16)

## Chain from pb_decode_delimited, Cost (336)
------------------------------------------------------------------------
  >pb_decode_delimited (32)
      >pb_decode (16)
          >pb_decode_noinit (104)
              >decode_field (80)
                  >pb_release_single_field (56)
                      >pb_release (32)
                          >pb_field_iter_next (16)

## Chain from pb_decode_delimited_noinit, Cost (320)
------------------------------------------------------------------------
  >pb_decode_delimited_noinit (32)
      >pb_decode_noinit (104)
          >decode_field (80)
              >pb_release_single_field (56)
                  >pb_release (32)
                      >pb_field_iter_next (16)

## Chain from pb_decode, Cost (304)
------------------------------------------------------------------------
  >pb_decode (16)
      >pb_decode_noinit (104)
          >decode_field (80)
              >pb_release_single_field (56)
                  >pb_release (32)
                      >pb_field_iter_next (16)

## Chain from pb_decode_nullterminated, Cost (304)
------------------------------------------------------------------------
  >pb_decode_nullterminated (0)
      >pb_decode (16)
          >pb_decode_noinit (104)
              >decode_field (80)
                  >pb_release_single_field (56)
                      >pb_release (32)
                          >pb_field_iter_next (16)

## Chain from pb_decode_noinit, Cost (288)
------------------------------------------------------------------------
  >pb_decode_noinit (104)
      >decode_field (80)
          >pb_release_single_field (56)
              >pb_release (32)
                  >pb_field_iter_next (16)

## Chain from decode_field, Cost (184)
------------------------------------------------------------------------
  >decode_field (80)
      >pb_release_single_field (56)
          >pb_release (32)
              >pb_field_iter_next (16)

## Chain from pb_release_single_field, Cost (104)
------------------------------------------------------------------------
  >pb_release_single_field (56)
      >pb_release (32)
          >pb_field_iter_next (16)

## Chain from initialize_pointer_field.isra.0, Cost (104)
------------------------------------------------------------------------
  >initialize_pointer_field.isra.0 (16)
      >pb_message_set_to_defaults (32)
          >pb_field_set_to_default (40)
              >iter_from_extension (16)

## Chain from pb_message_set_to_defaults, Cost (88)
------------------------------------------------------------------------
  >pb_message_set_to_defaults (32)
      >pb_field_set_to_default (40)
          >iter_from_extension (16)

## Chain from pb_dec_svarint, Cost (88)
------------------------------------------------------------------------
  >pb_dec_svarint (24)
      >pb_decode_svarint (24)
          >pb_decode_varint (32)
              >pb_readbyte (8)

## Chain from pb_dec_fixed_length_bytes, Cost (72)
------------------------------------------------------------------------
  >pb_dec_fixed_length_bytes (32)
      >pb_decode_varint32 (0)
          >pb_decode_varint32_eof (32)
              >pb_readbyte (8)

## Chain from pb_decode_tag, Cost (72)
------------------------------------------------------------------------
  >pb_decode_tag (32)
      >pb_decode_varint32_eof (32)
          >pb_readbyte (8)

## Chain from pb_dec_varint, Cost (72)
------------------------------------------------------------------------
  >pb_dec_varint (32)
      >pb_decode_varint (32)
          >pb_readbyte (8)

## Chain from pb_make_string_substream, Cost (64)
------------------------------------------------------------------------
  >pb_make_string_substream (24)
      >pb_decode_varint32 (0)
          >pb_decode_varint32_eof (32)
              >pb_readbyte (8)

## Chain from pb_decode_svarint, Cost (64)
------------------------------------------------------------------------
  >pb_decode_svarint (24)
      >pb_decode_varint (32)
          >pb_readbyte (8)

## Chain from pb_dec_string, Cost (64)
------------------------------------------------------------------------
  >pb_dec_string (24)
      >pb_decode_varint32 (0)
          >pb_decode_varint32_eof (32)
              >pb_readbyte (8)

## Chain from pb_dec_uvarint, Cost (64)
------------------------------------------------------------------------
  >pb_dec_uvarint (24)
      >pb_decode_varint (32)
          >pb_readbyte (8)

## Chain from pb_dec_bytes, Cost (64)
------------------------------------------------------------------------
  >pb_dec_bytes (24)
      >pb_decode_varint32 (0)
          >pb_decode_varint32_eof (32)
              >pb_readbyte (8)

## Chain from pb_field_set_to_default, Cost (56)
------------------------------------------------------------------------
  >pb_field_set_to_default (40)
      >iter_from_extension (16)

## Chain from pb_decode_bool, Cost (56)
------------------------------------------------------------------------
  >pb_decode_bool (0)
      >pb_dec_bool (16)
          >pb_decode_varint32 (0)
              >pb_decode_varint32_eof (32)
                  >pb_readbyte (8)

## Chain from pb_dec_bool, Cost (56)
------------------------------------------------------------------------
  >pb_dec_bool (16)
      >pb_decode_varint32 (0)
          >pb_decode_varint32_eof (32)
              >pb_readbyte (8)

## Chain from pb_skip_field, Cost (56)
------------------------------------------------------------------------
  >pb_skip_field (16)
      >pb_decode_varint32 (0)
          >pb_decode_varint32_eof (32)
              >pb_readbyte (8)

## Chain from pb_decode_fixed32, Cost (48)
------------------------------------------------------------------------
  >pb_decode_fixed32 (16)
      >pb_read (32)

## Chain from pb_decode_fixed64, Cost (48)
------------------------------------------------------------------------
  >pb_decode_fixed64 (16)
      >pb_read (32)

## Chain from pb_dec_fixed64, Cost (48)
------------------------------------------------------------------------
  >pb_dec_fixed64 (0)
      >pb_decode_fixed64 (16)
          >pb_read (32)

## Chain from pb_release, Cost (48)
------------------------------------------------------------------------
  >pb_release (32)
      >pb_field_iter_next (16)

## Chain from pb_close_string_substream, Cost (48)
------------------------------------------------------------------------
  >pb_close_string_substream (16)
      >pb_read (32)

## Chain from pb_dec_fixed32, Cost (48)
------------------------------------------------------------------------
  >pb_dec_fixed32 (0)
      >pb_decode_fixed32 (16)
          >pb_read (32)

## Chain from pb_decode_varint32, Cost (40)
------------------------------------------------------------------------
  >pb_decode_varint32 (0)
      >pb_decode_varint32_eof (32)
          >pb_readbyte (8)

## Chain from pb_decode_varint, Cost (40)
------------------------------------------------------------------------
  >pb_decode_varint (32)
      >pb_readbyte (8)

## Chain from pb_decode_varint32_eof, Cost (40)
------------------------------------------------------------------------
  >pb_decode_varint32_eof (32)
      >pb_readbyte (8)

## Chain from pb_field_iter_find, Cost (32)
------------------------------------------------------------------------
  >pb_field_iter_find (16)
      >pb_field_iter_next (16)

## Chain from pb_read, Cost (32)
------------------------------------------------------------------------
  >pb_read (32)

## Chain from iter_from_extension, Cost (16)
------------------------------------------------------------------------
  >iter_from_extension (16)

## Chain from pb_field_iter_next, Cost (16)
------------------------------------------------------------------------
  >pb_field_iter_next (16)

## Chain from allocate_field, Cost (16)
------------------------------------------------------------------------
  >allocate_field (16)

## Chain from pb_istream_from_buffer, Cost (8)
------------------------------------------------------------------------
  >pb_istream_from_buffer (8)

## Chain from pb_readbyte, Cost (8)
------------------------------------------------------------------------
  >pb_readbyte (8)

## Chain from buf_read, Cost (8)
------------------------------------------------------------------------
  >buf_read (8)

## Chain from pb_field_iter_begin, Cost (0)
------------------------------------------------------------------------
  >pb_field_iter_begin (0)

## Chain from INTERRUPT, Cost (0)
------------------------------------------------------------------------


The following functions were not resolved:
  memcpy
  realloc
  free
  memset
