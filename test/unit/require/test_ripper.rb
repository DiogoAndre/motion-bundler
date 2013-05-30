require File.expand_path("../../../test_helper", __FILE__)

module Unit
  module Require
    class TestRipper < MiniTest::Unit::TestCase

      describe MotionBundler::Require::Ripper do
        it "should be able to resolve require paths" do
          app_builder = mock "object"
          app_builder.expects(:requires).returns [
            [:require, ["stringio"]],
            [:require, ["strscan"]]
          ]
          MotionBundler::Require::Ripper::Builder.expects(:new).with("./app/controllers/app_controller.rb").returns app_builder

          foo_builder = mock "object"
          foo_builder.expects(:requires).returns [
            [:require, ["baz"]],
            [:require_relative, ["qux"]],
            [:require_relative, ["bar"]]
          ]
          MotionBundler::Require::Ripper::Builder.expects(:new).with("./app/controllers/foo_controller.rb").returns foo_builder

          baz_builder = mock "object"
          baz_builder.expects(:requires).returns []
          MotionBundler::Require::Ripper::Builder.expects(:new).with("./app/controllers/baz_controller.rb").returns baz_builder

          qux_builder = mock "object"
          qux_builder.expects(:requires).returns []
          MotionBundler::Require::Ripper::Builder.expects(:new).with("./app/controllers/qux.rb").returns qux_builder

          bar_builder = mock "object"
          bar_builder.expects(:requires).returns []
          MotionBundler::Require::Ripper::Builder.expects(:new).with(File.expand_path("./app/controllers/bar.rb")).returns bar_builder

          stringio_builder = mock "object"
          stringio_builder.expects(:requires).returns []
          MotionBundler::Require::Ripper::Builder.expects(:new).with("stdlib/stringio.rb").returns stringio_builder

          strscan_builder = mock "object"
          strscan_builder.expects(:requires).returns []
          MotionBundler::Require::Ripper::Builder.expects(:new).with("mocks/strscan.rb").returns strscan_builder

          lib_baz_builder = mock "object"
          lib_baz_builder.expects(:requires).returns []
          MotionBundler::Require::Ripper::Builder.expects(:new).with("lib/baz.rb").returns lib_baz_builder

          MotionBundler::Require.expects(:resolve).with("stringio").returns("stdlib/stringio.rb")
          MotionBundler::Require.expects(:resolve).with("strscan").returns("mocks/strscan.rb")
          MotionBundler::Require.expects(:resolve).with("baz").returns("lib/baz.rb")

          ripper = MotionBundler::Require::Ripper.new(
            "./app/controllers/app_controller.rb",
            "./app/controllers/foo_controller.rb",
            "./app/controllers/baz_controller.rb",
            "./app/controllers/qux.rb"
          )

          assert_equal([
            "./app/controllers/app_controller.rb",
            "stdlib/stringio.rb",
            "mocks/strscan.rb",
            "./app/controllers/foo_controller.rb",
            "lib/baz.rb",
            File.expand_path("app/controllers/qux.rb"),
            File.expand_path("app/controllers/bar.rb")
          ], ripper.files)
          assert_equal({
            "./app/controllers/app_controller.rb" => [
              "stdlib/stringio.rb",
              "mocks/strscan.rb"
            ],
            "./app/controllers/foo_controller.rb" => [
              "lib/baz.rb",
              File.expand_path("app/controllers/qux.rb"),
              File.expand_path("app/controllers/bar.rb")
            ]
          }, ripper.files_dependencies)
          assert_equal({
            "./app/controllers/app_controller.rb" => %w(
              stringio
              strscan
            ),
            "./app/controllers/foo_controller.rb" => %w(
              baz
              qux
              bar
            )
          }, ripper.requires)
        end

      end

    end
  end
end