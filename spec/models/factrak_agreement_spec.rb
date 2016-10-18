RSpec.describe FactrakAgreement do

  [:survey, :user, :agrees].each do |attr|
    it "validates presence of #{attr}" do
      expect(Fabricate.build(:factrak_agreement, attr => nil)).not_to be_valid
    end
  end

  it "validates user not survey owner" do
    survey = Fabricate(:factrak_survey)
    user = survey.user
    agreement = Fabricate.build(:factrak_agreement, user: user, survey: survey)
    expect(agreement).not_to be_valid
  end
end
