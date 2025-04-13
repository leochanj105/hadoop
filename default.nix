{ pkgs ? import <nixpkgs> {}
, withTests ? false
, lumosTracingFramework
}:

let
  inherit (pkgs)
    lib
    callPackage
    fetchFromGitHub
    fetchurl
    maven
    jdk8
    aspectj;

  cherrypiejamNurPackages = callPackage (fetchFromGitHub {
    owner = "cherrypiejam";
    repo = "nur-packages";
    rev = "81742efc8375ffe23f854f0ec938f5bb736483fb";
    hash = "sha256-SfLMDb8+mv9eeXhESPITAsWzl3aTo4Q3ldijrUah0+4=";
  }) { };

  tomcatSrc = fetchurl {
    url = "https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.44/bin/apache-tomcat-6.0.44.tar.gz";
    sha256 = "sha256-qreSMi51xlAmdRIJM8vFGc+1msjRkvT6EDNxozVwgiQ=";
  };

in

maven.buildMavenPackage rec {
  pname = "hadoop";
  version = "0.0.1";

  src = ./.;

  mvnHash = "sha256-G8dk0iu4RzclJGM5vy8lcp42xoINK9m/Gfxfb2wNDlA=";

  mvnParameters = lib.escapeShellArgs ([
    "clean"
    "install"
    "-U"
    "package"
    "-Pdist"
    "-Dmaven.javadoc.skip=true"
    ## This supports building a subset of the project. Since unwanted
    ## subprojects are already commented out in configuration, we just
    ## need to build the whole project.
    # "-pl"
    # "hadoop-hdfs-project,hadoop-common-project,hadoop-dist"
    # "-am"
    # "-amd"
  ]
  ++ (if withTests
    # -DskipTests compiles tests without running them.
   then [ "-DskipTests=true" ]
   else [ "-Dmaven.test.skip=true" ]
  ));

  nativeBuildInputs = [
    cherrypiejamNurPackages.protobuf_2_5_0
    jdk8
    aspectj
    lumosTracingFramework
  ];

  HADOOP_PROTOC_PATH = lib.getExe'
    cherrypiejamNurPackages.protobuf_2_5_0 "protoc";

  LUMOS_TRACING_FRAMEWORK_PATH = "${lumosTracingFramework}/dist";

  mvnJdk = jdk8;

  mvnFetchExtraArgs = {
    inherit
      HADOOP_PROTOC_PATH
      LUMOS_TRACING_FRAMEWORK_PATH;

    preBuild = ''
      set -x
      mkdir -p $out

      # Correctly building it requires dependencies from the
      # tracing framework. Let's copy them over to the cache.
      cp -dpR ${lumosTracingFramework.fetchedMavenDeps}/.m2 $out
      chmod +w -R $out/.m2
    '';
  };

  afterDepsSetup = ''
    TOMCAT_DOWNLOAD_DIR=hadoop-hdfs-project/hadoop-hdfs-httpfs/downloads
    mkdir -p $TOMCAT_DOWNLOAD_DIR
    cp --no-preserve=mode,ownership ${tomcatSrc} $TOMCAT_DOWNLOAD_DIR/apache-tomcat-6.0.44.tar.gz
  '';

  postInstall = ''
    cp -r . $out
  '';
}
