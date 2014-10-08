module StradiTest
  module Data
    def setup_dummy_schema
      ActiveRecord::Base.class_eval do
        connection.instance_eval do
          create_table :users, :force => true do |t|
            t.string :name
            t.string :email
          end
          create_table :posts, :force => true do |t|
            t.string  :title, :body
            t.integer :user_id
          end
          create_table :foos, :force => true do |t|
            t.string  :name, :text_field, :string_field
            t.datetime :created_at, :updated_at
            t.boolean :boolean_field
          end
        end
      end
    end
  end
end