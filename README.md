# Decidim KS – public consultation platform

The project's main objective is to launch a new digital service for the City of Warsaw: an online platform integrated with selected urban digital solutions to support the city's consultative processes.

Decidim KS is a platform that facilitates public participation in decision-making. Citizens can submit opinions, feedback, and ideas on projects and issues, take part in surveys and discussions, and provide input to inform policies, plans, and initiatives.

This is the open-source repository for decidim-warsaw-ks, built on [Decidim](https://github.com/decidim/decidim).

## Modules

The software is based on the Decidim 0.29.3 solution. It is a system that includes ready-made modules. During the development work, additional modules were produced, extending the functionality of existing modules or adding new modules to the system. All modules are an integral part of the platform, stored in the GIT repository and installed together as one application.

### Stock modules

| # | Module                  | Gem name                        |
| - | ----------------------- | ------------------------------- |
| 1 | Participatory processes | decidim-participatory_processes |
| 2 | Assemblies              | decidim-assemblies              |
| 3 | Initiatives             | decidim-initiatives             |
| 4 | Consultations           | decidim-consultations           |
| 5 | Conferences             | decidim-conferences             |

### Custom and extended modules

| #  | Module                  | Gem name                                 | Description                                                                                                                                                                        |
|----| ----------------------- |------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | AD Users                | decidim-ad_users_space                   | Active Directory integration adds the ability authentication internal users and control their activity in the system                                                               |
| 2  | Admin extended          | decidim-admin_extended                   | Expanded with custom features such as managing the main menu, notifications, and a dictionary of vulgar words.                                                                     |
| 3  | Consultation map        | decidim-consultation_map                 | The consultation map is an element of the participatory process that allows users to create comments marked on the map in various categories defined by the administrator          |
| 4  | Consultation requests   | decidim-consultation_requests            | Consultation request is new type of content to submit requests for public consultations by residents                                                                               |
| 5  | Core extended           | decidim-core_extended                    | Extended core system to custom features such as main system settings, unsubscribing from notifications and newsletters, new templates.                                             |
| 6  | Custom proposals        | decidim-module-custom_proposals          | The custom proposals is a simplified version of the Proposals - Participatory texts functionality. The administrator manually adds paragrafs of document commented by users.       |
| 7  | General plan request    | decidim-module-general_plan_requests     | General plan request component is a form for collecting comments on the General Plan document (a document in Polish law that is consulted with residents)                          |
| 8  | Expert questions        | decidim-expert_questions                 | The expert question is a participatory process component that allows users to ask designated experts questions                                                                     |
| 9  | Repository              | decidim-module-repository                | Repository adds the ability media and files management by administarators.                                                                                                         |
| 10  | REST API                | decidim-module-rest_api                  | Adds API allowing integrations with other systems                                                                                                                                  |
| 11 | Study notes             | decidim-module-study_notes               | The new participatory process component that allows users to submitting resident comments on the general plan.                                                                          |
| 12 | WS notification         | decidim-module-ws_notification           | Notification management integrated with the city notification system.                                                                                                              |
| 13 | News                    | decidim-news                             | This is a special model with new types of content, such as current news and information. Accessible from the home page or main menu.                                               |
| 14 | Pages extended          | decidim-pages_extended                   | Extended to custom features such as special form for contacts, faq, adding attachments and galleries.                                                                              |
| 15 | Participatory processes | decidim-participatory_processes_extended | Extended process space to custom features such as additional fields in the process description, file attachments, marking the consultation area on the map.                        |
| 16 | Remarks                 | decidim-remarks                          | The remarks is a participatory process component that allows users to comment and discuss the topic of the consultation                                                            |
| 17 | Users extended          | decidim-users_extended                   | Extended user aaccount setup and registration such as interests and notifications.                                                                                                 |
| 18 | Custom AI          | decidim-module-custom_ai                   | The AI module for handling high volumes of resident feedback submitted via survey, along with administrative tools.                                                                                                 |

## License

The application is based on a license: [Affero GPL Affero 3](LICENSE-AGPLv3.txt).

Additionally, following documents were translated to Polish:

- [AGPLv3 License](docs/license-AGPLv3-pl.md)
- [Decidim Social Contract](docs/license-decidim-pl.md)

These translations are NOT legally binding.

## Warranty and support

The City of Warsaw does not guarantee the proper functioning of the shared source code of the software and does not provide any support for it.

## Installation

The official guide on how to install, set up and upgrade Decidim. See the [Getting started guide](https://docs.decidim.org/en/install/). Linux and the required system libraries are necessary for the installation.

```
git clone https://github.com/City-of-Warsaw/decidim-warsaw-ks.git
cd decidim-warsaw-ks
bundle install
```

## Setting up the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Create system admin user with `rails decidim_system:create_admin`
2. Visit `<your app url>/system` and login with your system admin credentials
3. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
4. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
5. Fill the rest of the form and submit it.
6. Use /letter_opener to confirm admin user account and login.

You're good to go!

## Source code documentation

The documentation was generated using the tool [YARD](https://yardoc.org).
You can find it in the directory: [/doc](doc/index.html).

To regenerate or update the documentation, install the tool with the command:
`$ gem install yard`\
next in the root directory of app run the command:
`$ yardoc`