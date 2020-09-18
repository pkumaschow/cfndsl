CloudFormation {
  Description "Test"
  Parameter("One") {
    String
    Default "Test"
    MaxLength 15
  }

  Output(:One,FnBase64( Ref("One")))

  EC2_Instance(:myInstance1) {
    ImageId "ami-12345678"
  }

  Resource(:myInstance2) do
    Type 'AWS::EC2::Instance'
    Property "ImageId", "ami-12345678"
    Property "Type", "t2.micro"
    volumeProperties = [{
      Name: "vol1",
      Host: {
        SourcePath: "/var/app/vol1"
      }
    }, {
      Name: "vol2",
      Host: {
        SourcePath: "/var/app/vol2"
      }
    }]

    volumeProperties.push({
      Name: "vol3",
      Host: {
        SourcePath: "/var/app/vol3"
      }
    })
    Property "Volumes", volumeProperties
  end

}
