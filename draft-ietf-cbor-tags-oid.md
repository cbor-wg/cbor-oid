---
title: >
  Concise Binary Object Representation (CBOR) Tags for Object Identifiers
abbrev: CBOR Tags for OIDs
docname: draft-ietf-cbor-tags-oid-latest
date: 2021-05-21

stand_alone: true

ipr: trust200902
keyword: Internet-Draft
cat: std
consensus: true

pi: [toc, [tocdepth, 2], sortrefs, symrefs, compact, comments]

author:
  -
    ins: C. Bormann
    name: Carsten Bormann
    org: Universität Bremen TZI
    street: Postfach 330440
    city: Bremen
    code: D-28359
    country: Germany
    phone: +49-421-218-63921
    email: cabo@tzi.org

contributor:
  -
    ins: S. Leonard
    name: Sean Leonard
    email: dev+ietf@seantek.com
#    uri: http://www.penango.com/
    org: Penango, Inc.
    street:
      - 5900 Wilshire Boulevard
      - 21st Floor
    city: Los Angeles, CA
    code: 90036
    country: USA


normative:
  RFC6256: sdnv
  RFC8949: cbor
  RFC8610: cddl
  X.660:
    title: >
      Information technology —
      Procedures for the operation of object identifier registration authorities:
      General procedures and top arcs of the international object identifier tree
    author:
      org: International Telecommunications Union
    date: 2011-07
    seriesinfo:
      ITU-T: Recommendation X.660
    target: https://www.itu.int/rec/T-REC-X.660

  X.680:
    title: >
      Information technology — Abstract Syntax Notation One (ASN.1):
      Specification of basic notation
    author:
      org: International Telecommunications Union
    date: 2015-08
    seriesinfo:
      ITU-T: Recommendation X.680
    target: https://www.itu.int/rec/T-REC-X.680

  X.690:
    title: >
      Information technology — ASN.1 encoding rules:
      Specification of Basic Encoding Rules (BER), Canonical Encoding
      Rules (CER) and Distinguished Encoding Rules (DER)
    author:
      org: International Telecommunications Union
    date: 2015-08
    seriesinfo:
      ITU-T: Recommendation X.690
    target: https://www.itu.int/rec/T-REC-X.690

informative:
  X.672:
    title: >
      Information technology — Open systems interconnection —
      Object identifier resolution system
    author:
      org: International Telecommunications Union
    date: 2010-08
    seriesinfo:
      ITU-T: Recommendation X.672
    target: https://www.itu.int/rec/T-REC-X.672
  PCRE:
      target: http://www.pcre.org/
      title: PCRE - Perl Compatible Regular Expressions
      author:
        - name: Andrew Ho
      date: 2018
  OID-INFO:
    target: http://www.oid-info.com/
    title: >
      OID Repository
    author:
      org: Orange SA
    date: 2016

--- abstract


The Concise Binary Object Representation (CBOR, RFC 8949) is a data
format whose design goals include the possibility of extremely small
code size, fairly small message size, and extensibility without the
need for version negotiation.

The present document defines CBOR tags for
object identifiers (OIDs).  It is intended
as the reference document for the IANA registration of the CBOR tags
so defined.

--- middle

Introduction        {#intro}
============

The Concise Binary Object Representation (CBOR, {{-cbor}}) provides
for the interchange of structured data without a requirement for a
pre-agreed schema.
{{-cbor}} defines a basic set of data types, as well as a tagging
mechanism that enables extending the set of data types supported via
an IANA registry.

The present document defines CBOR tags for object identifiers
(OIDs, {{X.660}}), which many IETF protocols carry.
The ASN.1 Basic Encoding Rules
(BER, {{X.690}}) specify binary encodings of both (absolute) object identifiers
and relative object identifiers.
The contents of these encodings (the "value" part of BER's
type-length-value structure) can be carried in a CBOR byte string.
This document defines two CBOR tags that cover the two kinds of
ASN.1 object identifiers encoded in this way, and a third one to enable a
common optimization.
The tags can also be applied to arrays and maps to efficiently tag all
elements of an array or all keys of a map.
It is intended as the reference document for the IANA registration of
the tags so defined.

Terminology         {#terms}
------------

{::boilerplate bcp14}

The terminology of {{-cbor}} applies; in particular
the term "byte" is used in its now customary sense as a synonym for
"octet".
The verb "to tag (something)" is used to express the construction of a
CBOR tag with the object (something) as the tag content and a tag
number indicated elsewhere in the sentence (for instance in a "with"
clause, or by the shorthand "an NNN tag" for "a tag with tag number NNN").
The term "SDNV" (Self-Delimiting Numeric Value) is used as defined in
{{-sdnv}}, with the additional restriction detailed in {{reqts}} (no
leading zeros).

Object Identifiers {#oids}
========================

The International Object Identifier tree {{X.660}} is
a hierarchically managed space of
identifiers, each of which is uniquely represented as a sequence of
unsigned integer values
{{X.680}}.
(These integer values are called "primary integer values" in X.660
because they can be accompanied by (not necessarily unambiguous)
secondary identifiers.  We ignore the latter and simply use the term
"integer values" here, occasionally calling out their unsignedness.
We also use the term "arc" when the focus is on the edge of the tree
labeled by such an integer value, as well as in the sense of a "long
arc", i.e., a (sub)sequence of such integer values.)

While these sequences can easily be represented in CBOR arrays of
unsigned integers, a more compact representation can often be achieved
by adopting the widely used representation of object identifiers
defined in BER; this representation may also be more amenable to
processing by other software that makes use of object identifiers.

BER represents the sequence of unsigned integers by concatenating
self-delimiting {{-sdnv}} representations of each of the integer values in sequence.

ASN.1 distinguishes absolute object identifiers (ASN.1 Type `OBJECT IDENTIFIER`),
which begin at a root arc ({{X.660}} Clause 3.5.21), from relative object
identifiers (ASN.1 Type `RELATIVE-OID`), which begin
relative to some object identifier known from context ({{X.680}}
Clause 3.8.63).
As a special optimization,
BER combines the first two integers in an absolute object identifier
into one numeric identifier by making use of the property of the
hierarchy that the first arc has only three integer values (0, 1, and 2),
and the second arcs under 0 and 1 are limited to the integer values between
0 and 39.  (The root arc `joint-iso-itu-t(2)` has
no such limitations on its second arc.)
If X and Y are the first two integer values,
the single integer value actually encoded is computed as:

> X * 40 + Y

The inverse transformation (again making use of the known ranges of X
and Y) is applied when decoding the object identifier.

Since the semantics of absolute and relative object identifiers
differ, and it is very common for companies to use self-assigned numbers
under the arc "1.3.6.1.4.1" (IANA Private Enterprise Number OID,
{{?IANA.enterprise-numbers}}) that adds 5 fixed bytes to an encoded OID value,
this specification defines three tags, collectively called the
"OID tags" here:

Tag number TBD111: used to tag a byte string as the {{X.690}} encoding of an
absolute object identifier (simply "object identifier" or "OID").

Tag number TBD110: used to tag a byte string as the {{X.690}} encoding of a relative
object identifier (also "relative OID").  Since the encoding of each
number is the same as for {{-sdnv}} Self-Delimiting Numeric Values
(SDNVs), this tag can also be used for tagging a byte string that
contains a sequence of zero or more SDNVs (or a more
application-specific tag can be created for such an application).

Tag TBD112: structurally like TBD110, but understood to be relative to
`1.3.6.1.4.1` (IANA Private Enterprise Number OID, {{?IANA.enterprise-numbers}}).  Hence, the
semantics of the result are that of an absolute object identifier.

## Requirements on the byte string being tagged {#reqts}

To form a valid tag, a byte string tagged with TBD111, TBD110, or TBD112
MUST be syntactically valid contents (the value part) for a BER
representation of an object identifier (Sections 8.19, 8.20, and 8.20
of {{X.690}}, respectively): A concatenation of zero or
more SDNV values, where each SDNV value is a sequence of one or more bytes that
all have their most significant bit set, except for the last byte,
where it is unset.
Also, the first byte of each SDNV cannot be a
leading zero in SDNV's base-128 arithmetic, so it cannot take the
value 0x80 (bullet (c) in Section 8.1.2.4.2 of {{X.690}}).

In other words:

* the byte string's first byte, and any byte that follows a byte that has the most significant
  bit unset, MUST NOT be 0x80 (this requirement requires expressing the
  integer values in their shortest form, with no leading zeroes)
* the byte string's last byte MUST NOT have the most significant bit set (this
  requirement excludes an incomplete final integer value)

If either of these invalid conditions are encountered, the tag is
invalid.

{{X.680}} restricts RELATIVE-OID values to have at least
one arc, i.e., their encoding would have at least one SDNV.
This specification permits
empty relative object identifiers; they may
still be excluded by application semantics.

To facilitate the search for specific object ID values, it is RECOMMENDED
that definite length encoding (see Section 3.2.3 of {{-cbor}}) is used
for the byte strings used as tag content for these tags.

The valid set of byte strings can also be expressed using regular
expressions on bytes, using no specific notation but resembling
{{PCRE}}.  Unlike typical regular expressions that operate on
character sequences, the following regular expressions take bytes as
their domain, so they can be applied directly to CBOR byte strings.

For byte strings with tag TBD111:

> `/^(([\x81-\xFF][\x80-\xFF]*)?[\x00-\x7F])+$/`

For byte strings with tag TBD110 or TBD112:

> `/^(([\x81-\xFF][\x80-\xFF]*)?[\x00-\x7F])*$/`

A tag with tagged content that does not conform to the applicable
regular expression is invalid.

## Preferred Serialization Considerations {#prefser}

For an absolute OID with a prefix of "1.3.6.1.4.1", representations
with both the TBD111 and TBD112 tags are applicable, where the
representation with TBD112 will be five bytes shorter (by leaving out
the prefix h'2b06010401' from the enclosed byte string).
This specification makes that shorter representation the preferred
serialization (see {{Sections 3.4 and 4.1 of RFC8949}}).
Note that this also implies that the Core Deterministic Encoding
Requirements ({{Section 4.2.1 of RFC8949}}) require the use of TBD112
tags instead of TBD111 wherever that is possible.


## Discussion {#discussion}

Staying close to the way object identifiers are encoded in ASN.1
BER makes back-and-forth translation easy; otherwise we would choose a
more efficient encoding.  Object
identifiers in IETF protocols
are serialized in dotted decimal form or BER form, so
there is an advantage in not inventing a third form.  Also,
expectations of the cost of encoding object identifiers are
based on BER; using a different encoding might not be aligned with
these expectations. If additional information about an OID is desired,
lookup services such as
the [OID Resolution Service (ORS)](#X.672)
and the [OID Repository](#OID-INFO) are available.


Basic Examples {#examples}
========

This section gives simple examples of an absolute and a relative
object identifier, represented via tag number TBD111 and TBD110,
respectively.

<!-- <note removeinrfc="true" markdown="1"> -->
RFC editor: These and other examples assume the allocation of 111 for
TBD111 and 110 for TBD110 and need to be changed if that isn't the
actual allocation.  Please remove this paragraph.
<!-- </note> -->

## Encoding of the SHA-256 OID

ASN.1 Value Notation:
: { joint-iso-itu-t(2) country(16) us(840) organization(1) gov(101)
    csor(3) nistalgorithm(4) hashalgs(2) sha256(1) }

Dotted Decimal Notation:
: 2.16.840.1.101.3.4.2.1


~~~~~~~~~~~
06                                # UNIVERSAL TAG 6
   09                             # 9 bytes, primitive
      60 86 48 01 65 03 04 02 01  # X.690 Clause 8.19
#      |   840  1  |  3  4  2  1    show component encoding
#   2.16         101
~~~~~~~~~~~
{: #fig-sha-ber title="SHA-256 OID in BER"}

~~~~~~~~~~~
D8 6F                             # tag(111)
   49                             # 0b010_01001: mt 2, 9 bytes
      60 86 48 01 65 03 04 02 01  # X.690 Clause 8.19
~~~~~~~~~~~
{: #fig-sha-cbor title="SHA-256 OID in CBOR"}

## Encoding of a MIB Relative OID

Given some OID (e.g., `lowpanMib`, assumed to be `1.3.6.1.2.1.226` {{?RFC7388}}),
to which the following is added:

ASN.1 Value Notation:
: { lowpanObjects(1) lowpanStats(1) lowpanOutTransmits(29) }

Dotted Decimal Notation:
: .1.1.29

~~~~~~~~~~~
0D                                # UNIVERSAL TAG 13
   03                             # 3 bytes, primitive
      01 01 1D                    # X.690 Clause 8.20
#      1  1 29                      show component encoding
~~~~~~~~~~~
{: #fig-mib-ber title="MIB relative object identifier, in BER"}

~~~~~~~~~~~
D8 6E                             # tag(110)
   43                             # 0b010_00011: mt 2 (bstr), 3 bytes
      01 01 1D                    # X.690 Clause 8.20
~~~~~~~~~~~
{: #fig-mib-cbor title="MIB relative object identifier, in CBOR"}

This relative OID saves seven bytes compared to the full OID encoding.

Tag Factoring with Arrays and Maps {#tfs}
============

The tag content of OID tags can be byte strings (as discussed above), but also CBOR arrays and maps.
The idea in the latter case is that
the tag construct is factored out from each individual item in the container;
the tag is placed on the array or map instead.

When the tag content of an OID tag is an array, this means
that the respective tag is imputed to all elements of the array that are
byte strings, arrays, or maps.  (There is no effect on other elements,
including text strings or tags.)
For example, when the tag content of a TBD111 tag is an array,
every array element that is a byte string
is an OID, and every element that is an array or map is in turn
treated as discussed here.

When the tag content of an OID tag is a map, this means that a tag
with the same tag number is imputed to all keys in the map that are byte
strings, arrays, or maps; again, there is no effect on keys of other major types.
Note that there is also no effect on the values in the map.

As a result of these rules, tag factoring in nested arrays and maps is supported.
For example,
a 3-dimensional array of OIDs can be composed by using
a single TBD111 tag containing an array of arrays of arrays
of byte strings. All such byte strings are then considered OIDs.


## Preferred Serialization Considerations

Where tag factoring with tag number TBD111 is used, some OIDs enclosed in the
tag may be encoded in a shorter way by using tag number TBD112 instead of
encoding an unadorned byte string.
This remains the preferred serialization (see also {{prefser}}).
However, this specification does not make the presence or absence of
tag factoring a preferred serialization; application protocols can
define where tag factoring is to be used or not (and will need to do
so if they have deterministic encoding requirements).

## Tag Factoring Example: X.500 Distinguished Name

Consider the X.500 distinguished name:

| Attribute Types                                                           | Attribute Values                |
| c (2.5.4.6)                                                               | US                              |
| l (2.5.4.7)<br/>s (2.5.4.8)<br/>postalCode (2.5.4.17)                     | Los Angeles<br/>CA<br/>90013    |
| street (2.5.4.9)                                                          | 532 S Olive St                  |
| businessCategory (2.5.4.15)<br/>buildingName (0.9.2342.19200300.100.1.48) | Public Park<br/>Pershing Square |
{: #tab-dn-data title="Example X.500 Distinguished Name"
   cols="l l" style="all"}

{{tab-dn-data}} has four "relative distinguished names" (RDNs). The
country (first) and street (third) RDNs are single-valued.
The second and fourth RDNs are multi-valued.

The equivalent representations in CBOR diagnostic notation ({{Section 8
of RFC8949}}) and CBOR are:


~~~~~~~~~~~
111([{ h'550406': "US" },
     { h'550407': "Los Angeles",
       h'550408': "CA",
       h'550411': "90013" },
     { h'550409': "532 S Olive St" },
     { h'55040f': "Public Park",
       h'0992268993f22c640130': "Pershing Square" }])
~~~~~~~~~~~
{: #fig-dn-cbor-diag title="Distinguished Name, in CBOR Diagnostic Notation"}

~~~~~~~~~~~
d8 6f                                      # tag(111)
   84                                      # array(4)
      a1                                   # map(1)
         43 550406                         # 2.5.4.6 (4)
         62                                # text(2)
            5553                           # "US"
      a3                                   # map(3)
         43 550407                         # 2.5.4.7 (4)
         6b                                # text(11)
            4c6f7320416e67656c6573         # "Los Angeles"
         43 550408                         # 2.5.4.8 (4)
         62                                # text(2)
            4341                           # "CA"
         43 550411                         # 2.5.4.17 (4)
         65                                # text(5)
            3930303133                     # "90013"
      a1                                   # map(1)
         43 550409                         # 2.5.4.9 (4)
         6e                                # text(14)
            3533322053204f6c697665205374   # "532 S Olive St"
      a2                                   # map(2)
         43 55040f                         # 2.5.4.15 (4)
         6b                                # text(11)
            5075626c6963205061726b         # "Public Park"
         4a 0992268993f22c640130    # 0.9.2342.19200300.100.1.48 (11)
         6f                                # text(15)
            5065727368696e6720537175617265 # "Pershing Square"
~~~~~~~~~~~
{: #fig-dn-cbor title="Distinguished Name, in CBOR (109 bytes)"}

(This example encoding assumes that all attribute values are UTF-8 strings,
or can be represented as UTF-8 strings with no loss of information.)

CDDL Control Operators {#control}
===================

Concise Data Definition Language (CDDL {{-cddl}}) specifications may
want to specify the use of SDNVs or SDNV
sequences (as defined for the tag content for TBD110).  This document
introduces two new control operators that can be applied to a target
value that is a byte string:

* `.sdnv`, with a control type that contains unsigned integers.  The
  byte string is specified to be encoded as an {{-sdnv}} SDNV (BER
  encoding) for the matching values of the control type.

* `.sdnvseq`, with a control type that contains arrays of unsigned
  integers.  The byte string is specified to be encoded as a sequence
  of {{-sdnv}} SDNVs (BER encoding) that decodes to an array of
  unsigned integers matching the control type.

* `.oid`, like `.sdnvseq`, except that the X*40+Y translation for
  absolute OIDs is included (see {{fig-dn-cddl-oid}}).

{{fig-dn-cddl}} shows an example for the use of `.sdnvseq` for a part
of a structure using OIDs that could be used in {{fig-dn-cbor}};
{{fig-dn-cddl-oid}} shows the same with the `.oid` operator.

~~~ cddl
country-rdn = {country-oid => country-value}
country-oid = bytes .sdnvseq [85, 4, 6]
country-value = text .size 2
~~~
{: #fig-dn-cddl title="Using .sdnvseq"}

~~~ cddl
country-rdn = {country-oid => country-value}
country-oid = bytes .oid [2, 5, 4, 6]
country-value = text .size 2
~~~
{: #fig-dn-cddl-oid title="Using .oid"}

Note that the control type need not be a literal; e.g., `bytes .oid
[2, 5, 4, *uint]` matches all OIDs inside OID arc 2.5.4,
`attributeType`.


CDDL typenames
==========

For the use with CDDL, the
typenames defined in {{tag-cddl}} are recommended:

~~~ cddl
oid = #6.111(bstr)
roid = #6.110(bstr)
pen = #6.112(bstr)
~~~
{: #tag-cddl title="Recommended typenames for CDDL"}


IANA Considerations {#iana}
============

## CBOR Tags

IANA is requested to assign in the 1+1 byte space (24..255) of the CBOR tags registry
{{!IANA.cbor-tags}} the CBOR tag numbers in {{tab-tag-values-new}}, with the
present document as the specification reference.

| Tag    | Data Item                   | Semantics                                                               | Reference                     |
|--------|-----------------------------|-------------------------------------------------------------------------|-------------------------------|
| TBD111 | byte string or array or map | object identifier (BER encoding)                                        | \[this document, {{oids}}] |
| TBD110 | byte string or array or map | relative object identifier (BER encoding); <br/>SDNV {{-sdnv}} sequence | \[this document, {{oids}}] |
| TBD112 | byte string or array or map | object identifier (BER encoding), relative to 1.3.6.1.4.1               | \[this document, {{oids}}] |
{: #tab-tag-values-new title="New Tag Numbers" cols="l 11eml r"}

## CDDL Control Operators


IANA is requested to assign in the CDDL Control Operators registry
{{!IANA.cddl}} the CDDL Control Operators in
{{tab-operators-new}}, with the present document as the specification
reference.

| Name     | Reference                     |
|----------|-------------------------------|
| .sdnv    | \[this document, {{control}}] |
| .sdnvseq | \[this document, {{control}}] |
| .oid     | \[this document, {{control}}] |
{: #tab-operators-new title="New CDDL Operators"}


Security Considerations
============

The security considerations of {{-cbor}} apply.

The encodings in Clauses 8.19 and 8.20 of {{X.690}} are quite compact and unambiguous,
but MUST be followed precisely to avoid security pitfalls.
In particular, the requirements set out in {{reqts}} of this document need to be
followed; otherwise, an attacker may be able to subvert a checking
process by submitting alternative representations that are later taken
as the original (or even something else entirely) by another decoder
supposed to be protected by the checking process.

OIDs and relative OIDs can always be treated as opaque byte strings.
Actually understanding the structure that was used for generating them
is not necessary, and, except for checking the structure requirements,
it is strongly NOT RECOMMENDED to perform any
processing of this kind (e.g., converting into dotted notation and
back) unless absolutely necessary.
If the OIDs are translated into other representations, the usual
security considerations for non-trivial representation conversions
apply; the integer values are unlimited in range.

An attacker might trick an application into using a byte string inside
a tag-factored data item, where the byte string is not actually
intended to fall under one of the tags defined here.  This may cause
the application to emit data with semantics different from what was
intended.  Applications therefore need to be restrictive with respect
to what data items they apply tag factoring to.


--- back

Change Log
==========
{: removeInRFC="true"}

Changes from -06 to -07
-----------------------

* Various editorial changes prompted by IESG feedback; clarify the
  usage of "SDNV" in this document (no leading zeros).
* Add security consideration about tag-factoring.
* Make TBD112, where applicable, the preferred serialization (and thus
  the required deterministic encoding) over TBD111.

Changes from -05 to -06
-----------------------

Add references to specific section numbers of {{X.690}} to better
explain validity of enclosed byte string.

Changes from -04 to -05
-----------------------

* Update acknowledgements, contributor list, and author list

Changes from -03 to -04
-----------------------

Process WGLC and shepherd comments:

* Update references (RFC 8949, URIs for ITU-T)
* Define arc for this document, reference SDN definition
* Restructure, small editorial clarifications


Changes from -02 to -03
-----------------------

* Add tag TBD112 for PEN-relative OIDs
* Add suggested CDDL typenames; reference RFC8610

Changes from -01 to -02
-----------------------

Minor editorial changes, remove some remnants, ready for WGLC.

Changes from -00 to -01
-----------------------

Clean up OID tag factoring.

Changes from -07 (bormann) to -00 (ietf)
---------------------------------

Resubmitted as WG draft after adoption.

Changes from -06 to -07
---------------------------------

Reduce the draft back to its basic mandate: Describe CBOR tags for
what is colloquially know as ASN.1 Object IDs.


Changes from -05 to -06
---------------------------------

Refreshed the draft to the current date ("keep-alive").

Changes from -04 to -05
---------------------------------

Discussed UUID usage in CBOR, and incorporated fixes
proposed by Olivier Dubuisson, including fixes regarding OID nomenclature.

Changes from -03 to -04
---------------------------------

Changes occurred based on limited feedback, mainly centered around
the abstract and introduction, rather than substantive
technical changes. These changes include:

* Changed the title so that it is about tags and techniques.

* Rewrote the abstract to describe the content more accurately,
  and to point out that no changes to the wire protocol are being proposed.

* Removed "ASN.1" from "object identifiers", as OIDs are independent of ASN.1.

* Rewrote the introduction to be more about the present text.

* Proposed a concise OID arc.

* Provided binary regular expression forms for OID validation.

* Updated IANA registration tables.


Changes from -02 to -03
---------------------------------

Many significant changes occurred in this version. These changes include:

* Expanded the draft scope to be a comprehensive CBOR update.

* Added OID-related sections: OID Enumerations,
  OID Maps and Arrays, and
  Applications and Examples of OIDs.

* Added Tag 36 update (binary MIME, better definitions).

* Added stub/experimental sections for X.690 Series Tags (tag «X»)
  and Regular Expressions (tag 35).

* Added technique for representing sets and multisets.

* Added references and fixed typos.

<!--  LocalWords:  CBOR extensibility IANA uint sint IEEE endian IETF
 -->
<!--  LocalWords:  signedness endianness ASN BER encodings OIDs OID
 -->
<!--  LocalWords:  Implementers SDNV SDNVs repurpose SDNV's UTF
 -->

Acknowledgments
===============
{: numbered="no"}

{{{Sean Leonard}}} started the work on this document in 2014 with an
elaborate proposal.
{{{Jim Schaad}}} provided a significant review of this document.
{{{Rob Wilton}}}'s IESG review prompted us to provide preferred
serialization considerations.
