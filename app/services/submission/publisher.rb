class Submission::Publisher
  attr_accessor :submission

  def initialize(submission)
    raise ArgumentError, "Submission not finalized" unless submission.finalized?

    self.submission = submission
  end

  def publish
    raise ArgumentError, "Submission is published" if submission.published?

    now = Time.zone.now
    submission.transaction do
      ActiveRecord::Base.delay_touching do
        submission.update_attributes!(published: true)
        publish_object(submission.submitted_object, now)
        associated_collections.each do |collection|
          collection.not_published.each { |instance| publish_object(instance, now) }
        end
      end
    end
  end

  def revoke
    raise ArgumentError, "Submission is not published" unless submission.published?
    raise ArgumentError, "Submission is not revocable" unless submission.revocable?

    submission.transaction do
      ActiveRecord::Base.delay_touching do
        submission.update_attributes!(published: false)
        revoke_object(submission.submitted_object)
        associated_collections.each do |collection|
          collection.each { |instance| revoke_object(instance) }
        end
      end
    end
  end

  private

  def publish_object(object, time)
    object.update_attributes!(published: true, published_on: time)
  end

  def revoke_object(object)
    object.update_attributes!(published: false, published_on: nil)
  end

  def associated_collections
    raise NotImplementedError, "Must be implemented by subclasses"
  end
end
