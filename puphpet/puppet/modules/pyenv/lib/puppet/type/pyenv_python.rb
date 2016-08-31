Puppet::Type.newtype(:pyenv_python) do

  @doc = <<-EOS
    This type provides Puppet with the capabilities to manage Pythons by
    leveraging pyenv. Pyenv automatically installs pip for you.

    pyenv_python { '3.4.0':
      ensure => 'present',
    }

    If you want to build a debug version of a Python add '-debug' to the
    resource name/title.

    Should you also want to install virtualenv in your new Python:

    pyenv_python { '2.7.6':
      ensure     => 'present',
      virtualenv => true,
    }

  EOS

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'The Python that should be installed'
    newvalues(/[\w.-]{3,}/)
  end

  newproperty(:keep) do
    desc 'Keep source tree in $PYENV_ROOT/sources after installation'
    newvalues(true, false)
    defaultto false
  end

  newproperty(:virtualenv) do
    desc 'Keep source tree in $PYENV_ROOT/sources after installation'
    newvalues(true, false)
    defaultto false
  end

end
