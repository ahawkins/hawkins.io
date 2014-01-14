Forms are border guards. All access to business logic goes through
forms. All the shit data coming from _where ever_ is transformed in
domain level Ruby objects. Form are objects are implemented with
Virtus. Virtus is another fantastic peice of software. It is
practically perfect of this use case. I can define custom
tranformations and convert hashes and god knows what else into my
domain classes. I also make these objects bitchy as hell. They are
bitchy for a reason. Anything that get's through them will never be
checked anywhere else in the entire subsystem so now foul ups here!
They are optimised for a few use cases. The most specific one is
grapping a blob of parameters and dumping them into an initializer.
They raise specific errors if an unknown parameter is given. They blow
up if a given value cannot be coerced. They do a few other things but
these are the most important. They ensure untrusted garbage input is
converted into the proper objects. This is the boundary between the
domain objects and the delivery mechanism.

```ruby
class CreateUserForm < Form
  attribute :name, String
  attribute :auth_token, String
  attribute :device, Hash

  validates :name, :auth_token, :device, presence: true

  validate do |form|
    next unless form.device

    uuid = form.device.fetch 'uuid', nil
    errors.add :device, "uuid cannot be blank" if uuid.blank?
  end
end
```
