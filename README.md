# Active Record - Models

## Review of relations/associations

OOP and RDBMS are fundamentally different in a few ways.
That's why we need ORMs.

There are similarities.

In a RDB you have foreign keys that allow you to join tables together.

  users

  id | username | password
  ---+----------+---------
  1  | david    | 12345

  posts

  id | title | content | user_id
  ---+-------+---------+--------
  1  | Short | In a wo | 1

In OOP you have objects that have references to other objects.

  class User
    attr_accessor :id, :username, :password
  end
  
  class Post
    attr_accessor :id, :title, :content, :user
  end
  
  user = User.new
  user.id = 1
  user.username = 'david'
  user.password = '12345'
  
  post = Post.new
  post.id = 1
  post.title = 'Short'
  post.content = 'In a world...'
  post.user = user
  
### One-to-one

ObjectA has_one ObjectB, and ObjectB belongs_to ObjectA

### One-to-many

ObjectA has_many ObjectB's, and an ObjectB belongs_to ObjectA

### Many-to-many (OOP only)

ObjectA has_and_belongs_to_many ObjectB's, 
and ObjectB has_and_belongs_to_many ObjectA's

#### Students and Courses

This example kinda works...

  class Student < ActiveRecord::Base
    has_and_belongs_to_many :courses
  end
  
  class Course < ActiveRecord::Base
    has_and_belongs_to_many :students
  end
  
  student = Student.create
  student.courses # should be a collection of Courses
  course = Course.create
  course.students # should be a collection of Students

...but it's limited. A more robust alternative is:

  class Student < ActiveRecord::Base
    has_many :enrollments
  end
  
  class Enrollment < ActiveRecord::Base
    belongs_to :student
    belongs_to :course
  end

  class Course < ActiveRecord::Base
    has_many :enrollments
  end

## Review of custom validations

There are two ways: a validator class (`validate_with`) or 
a method in the model (`validate`). You will almost never,
in your entire career, need a validator class.

### `validate_with` (rare)

It is used for when you have a generic validation
that applies to multiple different kinds of objects that are
not related in any way to each other. That is, one class does
not inherit from the class with the custom validation.

### `validate` (used all the time)

It is used when you have a constraint on a property (or multiple
properties) of an object type that is not covered by the built-in
Active Record validators.

  class Enrollment < ActiveRecord::Base
    # A course cannot be dropped before it was enrolled in
    validate :enrolled_at_before_dropped_at
    private
    def enrolled_at_before_dropped_at
      if enrolled_at && dropped_at && enrolled_at > dropped_at
        errors.add(:dropped_at, 'enrollment date must be before drop date')
      end
    end
  end

## Discussion of validation messages

  class Student < ActiveRecord::Base
    validates :date_of_birth, presence: true
  end
  
  s = Student.create! # will produce a good default error message
  
  class Course < ActiveRecord::Base
    validates :name, format: { with: /\A\d{4}\w+\Z/, message: 'must be in the format "####description_of_course"' }
  end

Some validations do the same thing:

  validates :something, numericality: { only_integer: true, greater_than: 5 }
  validates :something, numericality: { only_integer: true, greater_than_or_equal_to: 6 }

But the default error messages will differ. Be careful!

## Referential integrity

Refers to a concept in RDBMS, where a foreign key column value MUST
point to an existing value in the primary key column of the referenced
table. For example, if a `stores` database table contains rows with
primary keys 1, 2, 3, and 4, and an `employees` database table contains
a row whose `store_id` column contains the value 5, the data lacks
referential integrity.

To prevent your Active Record models from losing referential integrity,
always decide what happens when the owning side of a one-to-many
association is destroyed.

  class Store < ActiveRecord::Base
    has_many :employees, dependent: :destroy
  end
  
  class Employee < ActiveRecord::Base
    belongs_to :store
  end

`dependent: :destroy` registers a callback with default behaviour

## Callbacks

  class User < ActiveRecord::Base
    has_many :photos
    before_delete :give_away_photos_to_evil_website
    private
    def give_away_photos_to_evil_website
      photos.each do |photo|
        photo.user = nil
        photo.save
      end
    end
  end
  
  class Photo < ActiveRecord::Base
    belongs_to :user
    after_destroy :delete_photo_from_disk
    private
    def delete_photo_from_disk
      # Hypothetically, if File.remove fails to remove
      # the file from the file system, raises an error.
      File.remove(file_path)
      true
    rescue
      # If a method in a callback returns false, it cancels
      # the operation that was being performed. In this case
      # returning false will prevent the database record from
      # being deleted if the photo was not able to be removed.
      false
    end
  end

### Conditional callbacks

Callbacks optionally take an `if:` or an `unless:` argument
that is a reference to a method (as a symbol) and the callback
will only be called depending on the result of invoking the
method of that name on the model.

### Stopping the operation from proceeding

If a callback method returns false, the operation in progress is
canceled (rolled back.)

#### Preventing deletion example

  class User < ActiveRecord::Base
    validates :admin, inclusion: [true, false]
    before_destroy :admins_cant_be_destroyed, if: :admin?
    private
    def admins_cant_be_destroyed
      errors.add(:admin, 'Admins cannot be destroyed')
      false # returning exactly false prevents destruction from continuing
    end
  end

# Active Record - Migrations

Active Record allows you to specify changes to the schema of your database
using Ruby code.

Instead of:

  CREATE TABLE users (
    id serial NOT NULL PRIMARY KEY,
    username varchar(255) NOT NULL,
    created_at datetime,
    modified_at datetime
  );

You can use:

  create_table :users do |table|
    table.string :username
    table.timestamps null: true
  end

A big difference you'll notice is that the `id` column is added
to tables automatically. There are macros, such as `timestamps`
that add common columns with good defaults.

Additionally, migrations are reversible! You can rollback botched
migrations, fix them, and then redo them. How, you ask?

## Rake tasks

Rake is program that allows you to define common tasks that you would
want to do with a project, such as migrating a database, using Ruby
code.

## The db/migrate folder

## Migration classes

  class CreateUsers < ActiveRecord::Migration
    def change
      create_table :users do |t|
        t.string :username
        t.timestamps null: true
      end
    end
  end

## Reversible changes

# Development database configuration

## Development and test environments have different databases

## Switch between them using environment variables

## Seeding databases for different environments
