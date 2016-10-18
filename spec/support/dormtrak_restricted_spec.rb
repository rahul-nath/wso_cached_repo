shared_examples "dormtrak restricted" do
  [:professor, :alum, :staff].each do |user_type|
    context "as a #{user_type.to_s}" do
      include_context "#{user_type}"

      # This allows it to figure out its own controller class, and
      # calls only the methods defined by that controller itself
      self.controller_class.instance_methods(false).each do |action|
        context "get #{action}" do
          # In case it needs an id. eg for show. FOR ROUTING ONLY. If you see
          # an error related to not being able to find something with id: dummy,
          # for example, it shouldn't even be able to get to that point. Because
          # everything tested here should be filtered BEFORE it hits the method
          subject { get action, id: "dummy" }

          it "responds with 200" do
            expect(response.status).to eq(200)
          end

          it "redirects to root" do
            expect(subject).to redirect_to root_path
          end
        end
      end
    end
  end


  (self.controller_class.instance_methods(false) - [:policy, :accept_policy]).each do |action|
    context "user who has not accepted dormtrak policy" do
      include_context "user who has not accepted dormtrak policy"
      context "get #{action}" do
        subject { get action, id: "dummy" }

        it "redirects to policy" do
          expect(subject).to redirect_to dormtrak_policy_path
        end
      end
    end
  end
end
