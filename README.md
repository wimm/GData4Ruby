#GData4Ruby

##Introduction

GData4Ruby is a full featured wrapper for the Google Data base API.  GData4Ruby provides the ability
to authenticate with GData using the ClientLogin method.  The package also includes a base gdata object 
that can be subclassed to provide basic CRUD functions for all Google API service objects.  Additionally,
a basic ACL object is included for interacting with ACL feeds and setting access rules.

##Author and Contact Information

GData4Ruby was created and is maintained by [Mike Reich](mailto:mike@seabourneconsulting.com]) 
and is licenses under the LGPL v3.  You can find the text of the LGPL 
here: http://www.gnu.org/licenses/lgpl.html.  Feel free to use and update, but be sure to contribute your
code back to the project and attribute as required by the license.

##Website

[http://cookingandcoding.com/gdata4ruby/](http://cookingandcoding.com/gdata4ruby/)

##Description

GData4Ruby has three major components: the service, the GData object and the AccessRule object.  Each service
represents a google account, and includes a username (email) and a password.  You can use the GData service
to authenticate either a google account or a google apps account.

The GData object provides a base class for interacting with Google API objects, i.e. Documents, Events, etc.  The GData object contains common attributes present in all Google API objects, and provides interfaces for basic CRUD functions.  This class is meant to be subclassed.

The AccessRule object provides a base class for interacting with Google Access Control Lists.  ACLs provide the main permissions mechanism for most Google API services.

##Examples

Below are some common usage examples.  For more examples, check the documentation.

###Service

1. Authenticate

    service = Service.new
    service.authenticate("user@gmail.com", "password", "cl")

2. Authenticate with a specified GData version

    service = Service.new({:gdata_version => '3.0'})
    service.authenticate("user@gmail.com", "password", "cl")
