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

  propertyVolumes = []
  cdVolumes = {}
  (cdVolumes['MountPoints'] ||= []) << {
    ContainerPath: "/app/keys",
    SourceVolume: "authorisation-keys",
    Readonly: true
  }
  (cdVolumes['MountPoints'] ||= []) << {
    ContainerPath: "/app/ssh-keys",
    SourceVolume: "ssh-keys",
    Readonly: true
  }
  propertyVolumes = [{
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

  propertyVolumes.push({
    Name: "vol3",
    Host: {
      SourcePath: "/var/app/vol3"
    }
  })
 
  Resource(:myInstance2) do
    Type 'AWS::EC2::Instance'
    Property "ImageId", "ami-12345678"
    Property "Type", "t2.micro"
    Property "Volumes", propertyVolumes
  end

}
