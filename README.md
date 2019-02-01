## Hooking up data

This `DATA` environment setting
can be set to any "connection string";
see https://www.connectionstrings.com/

Site maintainers will likely want very tight control over this;
everyone is working with different data,
and it comes in all shapes and sizes.

Flexibility with storage is the least we can do
to ease the stress of the situation.

Further, this represents a common pattern in the Assemble framework:

You'll find that in a few places,
we boil down really complicated procedures
into a single, simple question.

In this case the question is,
"Where is your data?"

This setting can specify:

* A URL to a remote database-as-a-service provider
  (`postgres://database.....org`)

* A path to a persistant storage volume
  (`file://....txt`)

* Private deployment information,
  encoded as plaintext strings.
  (data:text/plain;charset=US-ASCII;base64,...===)

It even works with emoji.
