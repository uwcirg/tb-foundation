# RSwag Notes

Rswag is a DSL on top of the rspec testing framework that allows for easy generation of OpenApi Swagger documentation on top of test for your api   

## Generating Docs

Rswag files live in /spec/integration

You can ssh into the container and run `create_docs` alias to generate the documentation

## Adding docs for a new route

Check out the example for `get /v2/channels` in `spec/integration/channels_spec.rb`. The example runs like other tests, except when you generate the docs the tests don't actually run - just the DSL gets processed into a swagger.yml file

You can just copy this file and modify for the needs of the route you are documenting.

## Schemas

To save a lot of typing you can use the schemas defined in `/spec/swagger_helper.rb` to save time on repetition. You can define the keys in the response, their types, and example values.

Example: 
```
schemas: {
          channel:{
            type: "object",
            properties:{
              id: { type: "integer"},
              title: { type: "string", example: "General Discussion"},
              subtitle: {type: "string"},
              messagesCount: {type: "integer"},
              isPrivate: {type: "boolean"},
              updatedAt: {type: "string", format: "date-time"},
              userId: {type: "integer"},
              lastMessageTime: {type: "string", format: "date-time"},
              userType: {type: "string"},
              isSiteChannel: {type: "boolean"},
            }
          },
```

## Response with a list of objects

For some reason this is really poorly documented on the the Github Repo for RSwag. Check out this link to see how to do it [https://github.com/rswag/rswag/issues/195](https://github.com/rswag/rswag/issues/195)

This gist is to specify the schema as an array, and then link the items to your other defined schemas
```
  schema type:  :array,
    items: { '$ref' => '#/definitions/profile_search' }
```