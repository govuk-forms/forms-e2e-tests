# Capybara's Session#reset! method runs at the end of every test and includes a call to Storage.clearDataForOrigin with
# a wildcard origin argument. As of version 158, Chrome no longer supports the wildcard origin, so this call returns a
# Selenium::WebDriver::Error::InvalidArgumentError and causes the test to fail.
# This code monkey patches the call to Storage.clearDataForOrigin, removes all cookies, and then clears the other
# storage types for each domain we test.
# We can remove this patch once the upstream Capybara issue is fixed: https://github.com/teamcapybara/capybara/issues/2865

module SeleniumPatches
  module ClearStorageWithoutWildcardOrigin
  private

    def execute_cdp(cmd, params = {})
      return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

      types = params[:storageTypes].to_s.split(",")
      super("Network.clearBrowserCookies") if types.delete("cookies")

      origins = [
        Settings.forms_admin.url,
        Settings.forms_product_page.url,
        Settings.forms_runner.url,
      ]

      origins.each do |origin|
        super(cmd, params.merge(origin:, storageTypes: types.join(","))) if types.any?
      end
    end
  end
end
