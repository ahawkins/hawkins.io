Use cases take in a form and whatever external state (often the
current user) and do something. They are _use cases_. Use cases are
apporiately named: `CreateTodo`, `UploadPicture`, or `PostAd`. No REST
here! Domain use cases are isolated and agnostic. A use case has a
`run!` method (with varying signatures depending on context) and it
returns an object. Failures are communicate throw exceptions. I like
exceptions. I use exceptions much more often now. They sure prevent a
lot of weird stuff from happening. I usually have at least `ValidationError`
and `PermissionDeniedError`. I've never worked on app that didn't have
validations or some permissions. Each use case may raise its own
specific errors like `AccountCapacityExceededError` that only happen
when different objects are used in concert. I prefer this approach
because the containing delivery mechansim can capture the errors and
react accordingly. The errors are also very helpful in testing because
the classes describe the failure. This had made debugging random tests
so much easier because unexpected errors present themselves obviously.
How many times have written a test that fails in a werid way because
code assumed valid data? That happend a lot to me. It still happens,
but raising an error makes the root cause easy to diagnose.

Use cases are also fanastic because new use cases can simply be
composed of existing ones since they are isolated by design. I cannot
express how awesome this was when I saw it happen for the first time
in Radium. I had an existing use case: `CreateContact`. I had to write
a new use case: `SendEmail`. `SendEmail` was supposed to create new
contacts when it encountered unknown email addresses. At that moment I
realized I could simply instantiate a new `ContactForm` and
`CreateContact` use case and call them from inside `SendEmail`. It
worked perfectly the first time. I could never go back from that
moment. I actually consider it a defining moment in my software
development progression. I previously would've done that with a ton of
callbacks while violating a ton of boundaries and other sound design
principles. I cannot stress how imporant use cases are. The first time
you get to compose them it will be a mindly blowing moment. It was for
me.

```ruby
class AddPicture
  attr_reader :group_id, :form, :current_user

  def initialize(group_id, form, current_user)
    @group_id, @form, @current_user = group_id, form, current_user
  end

  def run!
    group = GroupRepo.find group_id

    authorize! group

    cloud = ImageService.upload form.file

    picture = Picture.new do |picture|
      picture.user = current_user

      picture.bytes = form.file.bytes

      picture.date = Time.now.utc

      picture.full_size_url = cloud.full_size_url
      picture.thumbnail_url = cloud.thumbnail_url
      picture.id = cloud.id

      picture.width = cloud.width
      picture.height = cloud.height
    end

    group.cover = picture if group.pictures.empty?

    group.pictures << picture

    group.save

    group.users.each do |recipient|
      next if recipient == current_user
      PushService.push(NewPicturePushNotification.new(picture, recipient))
    end

    picture
  end

  def authorize!(group)
    if !group.member? current_user
      raise PermissionDeniedError, "Only group members can add pictures"
    end
  end
end
```
