require 'swagger_helper'

describe 'Patient Password Reset Route' do

  path '/patients/:patient_id/password-reset' do

    post 'Resets a patients password' do
      tags 'Patient'

      response '200', 'password reset' do
        let(:blog) { { title: 'foo', content: 'bar' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:blog) { { title: 'foo' } }
        run_test!
      end
    end
  end

  path '/blogs/{id}' do

    get 'Retrieves a blog' do
      tags 'Blogs'
      produces 'application/json', 'application/xml'
      parameter name: :id, in: :path, type: :string

      response '200', 'blog found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            content: { type: :string }
          },
          required: [ 'id', 'title', 'content' ]

        let(:id) { Blog.create(title: 'foo', content: 'bar').id }
        run_test!
      end

      response '404', 'blog not found' do
        let(:id) { 'invalid' }
        run_test!
      end

      response '406', 'unsupported accept header' do
        let(:'Accept') { 'application/foo' }
        run_test!
      end
    end
  end
end