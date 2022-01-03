project_name: "democorp_thelookevent_ecomm"

application: ex_framework_lab {
  label: "First week extension"
  url: "http://localhost:8080/bundle.js"
  entitlements: {
    local_storage: yes
    navigation: yes
    new_window: yes
    core_api_methods: ["all_connections","search_folders", "run_inline_query", "me"]
  }
}
