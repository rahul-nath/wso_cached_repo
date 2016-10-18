# This file was created to allow both students and alums
# to have factrak surveys and things like that.
# This is because we are using single table inheritance,
# so the factrak survey could technically reference a user.
# The ways around that were to instead have the survey reference
# a student, via a student_id (which is really a user_id, and
# rails magically knows this). But, we needed a way to switch
# take a Student and convert them into an Alum, while preserving
# their factrak surveys and stuff. If using student_id, that no
# longer works once the Student becomes an Alum. Next we tried
# polymorphic relationships between them, so that surveys had
# a graduatable_id and graduatable_type, but this required modifying
# those 2 columsn in the table when we graduated the user. Plus it
# is extra overhead.
# This gets around that by only letting those models which include
# this module know about the association with stuff like factrak surveys,
# because only they have the has_many stuff. Then you need to set 
# user_id as the foreign key, because it will often look for a 
# student_id if you do something like Student.first.dormtrak_reviews.first
# when we actually want it to search users



module Graduatable
  extend ActiveSupport::Concern

  included do
    has_many :dormtrak_reviews, foreign_key: "user_id"
    has_many :factrak_surveys, foreign_key: "user_id"
    has_many :factrak_agreement, foreign_key: "user_id"
  end
end
