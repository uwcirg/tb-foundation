## Security

Pre-1.0, Assemble needs some work to ensure that user data stays secure.

The first requirement is the presence
of an RSA x.509 public/private keypair,
available in the container as:

```
/crypto/foundation.private.key
/crypto/foundation.public.certificate
```

Assemble will use this keypair to sign a JSON web token
for each browser that connects to it.

See `app/controllers/crypto_controller.rb` for detailed information.

- - -

## Hooking up data

This `DATA` environment setting
can be set to any "connection string";
see https://www.connectionstrings.com/

Site maintainers will likely want very tight control over this;
everyone is working with different data,
and it comes in all shapes and sizes.

Flexibility with storage is the least we can do
to ease the stress of the situation.

- - -


