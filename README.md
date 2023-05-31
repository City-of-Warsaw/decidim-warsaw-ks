# Decidim – consultation platform

The main objective of the Project is to launch a new digital service by the City of Warsaw in the form of an online Platform, integrated with other selected urban digital solutions, ready to support consultative processes carried out by the City of Warsaw.

Decidim KS is a platform designed to facilitate public participation and engagement in decision-making processes. Through this system, citizens can actively contribute their opinions, feedback, and ideas on various issues and projects. They can participate in surveys and discussions, providing valuable input to inform policies, plans and initiatives.

This is the open-source repository for decidim-warsaw-ks, based on [Decidim](https://github.com/decidim/decidim).

## Modules

The software is based on the Decidim 0.24.3 solution. It is a system that includes ready-made modules. During the development work, additional modules were produced, extending the functionality of existing modules or adding new modules to the system. All modules are an integral part of the platform, stored in the GIT repository and installed together as one application.

### Stock modules

| # | Module                  | Gem name                        |
| - | ----------------------- | ------------------------------- |
| 1 | Participatory processes | decidim-participatory_processes |
| 2 | Assemblies              | decidim-assemblies              |
| 3 | Initiatives             | decidim-initiatives             |
| 4 | Consultations           | decidim-consultations           |
| 5 | Conferences             | decidim-conferences             |

### Custom and extended modules

| #  | Module                  | Gem name                                 | Description                                                                                                       |
| -- | ----------------------- | ---------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| 1  | AD Users                | decidim-ad_users_space                   | Adds Active Directory integration and authentication                                                              |
| 2  | Admin extended          | decidim-admin_extended                   | Extended to develop custom features                                                                               |
| 3  | Comments extended       | decidim-comments_extended                | Extended to develop custom features                                                                               |
| 4  | Consultation map        | decidim-consultation_map                 | Adds new participatory process component that allows users to create remarks marked on a map                      |
| 5  | Consultation requests   | decidim-consultation_requests            | Adds new type of content: Consultation request                                                                    |
| 6  | Core extended           | decidim-core_extended                    | Extended to develop custom features                                                                               |
| 7  | Expert questions        | decidim-expert_questions                 | Adds new participatory process component that allows users to ask designated experts questions                    |
| 8  | Repository              | decidim-module-repository                | Adds media and files management                                                                                   |
| 9  | REST API                | decidim-module-rest_api                  | Adds API allowing integrations with other systems                                                                 |
| 10 | Study notes             | decidim-module-study_notes               | Adds new participatory process component that allows users to send comments on planning documents, including maps |
| 11 | WS notification         | decidim-module-ws_notification           | Adds custom notifications system integration                                                                      |
| 12 | News                    | decidim-news                             | Adds new type of content: News                                                                                    |
| 13 | Pages extended          | decidim-pages_extended                   | Extended to develop custom features                                                                               |
| 14 | Participatory processes | decidim-participatory_processes_extended | Extended to develop custom features                                                                               |
| 15 | Remarks                 | decidim-remarks                          | Adds new participatory process component that allows users to send remarks                                        |
| 16 | Users extended          | decidim-users_extended                   | Extended to develop custom features                                                                               |

## License

The application is based on a license: [Affero GPL Affero 3](LICENSE-AGPLv3.txt).

Additionally, following documents were translated to Polish:

- [AGPLv3 License](docs/license-AGPLv3-pl.md)
- [Decidim Social Contract](docs/license-decidim-pl.md)

These translations are NOT legally binding.

## Warranty and support

The City of Warsaw does not guarantee the proper functioning of the shared source code of the software and does not provide any support for it.

## Installation

```
git clone https://github.com/City-of-Warsaw/decidim-warsaw-ks.git
cd decidim-warsaw-ks
bundle install
```

## Setting up the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Open a Rails console in the server: `bundle exec rails console`
2. Create a System Admin user:
```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```
3. Visit `<your app url>/system` and login with your system admin credentials
4. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
5. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
6. Fill the rest of the form and submit it.

You're good to go!

The official guide on how to install, set up and upgrade Decidim. See the [Getting started guide](https://docs.decidim.org/en/install/).

## Source code documentation

The documentation was generated using the tool [YARD](https://yardoc.org).
You can find it in the directory: [/doc](doc/index.html).

To regenerate or update the documentation, install the tool with the command:
`$ gem install yard`\
next in the root directory of app run the command:
`$ yardoc`