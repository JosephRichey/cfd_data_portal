# An app that allows officers to add, manage, and record training
# and roster information. This also includes an analysis pane.


# 50 Hours

box::use(
  shiny[...],
  bslib[...],
  DT[...],
)

box::use(
  view/training,
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  page_navbar(
    title = "Corinne Fire Department",
    theme = bs_theme(version = 5,
                     success = "#87292b",
                     bootswatch = "darkly"),
    nav_panel(title = "Training",
              layout_sidebar(
                sidebar = sidebar(
                  width = 400,
                  open = "desktop",
                  training$UI(ns('training'))
                ),
                training$Output(ns('training'))
              )
    ),

  #   nav_panel(title = "Manage Roster",
  #             layout_sidebar(
  #               sidebar = sidebar(actionButton('add_firefighter', 'Add Firefighter'),
  #                                 actionButton('remove_firefighter', 'Remove Firefighter')
  #               ),
  #               card(DTOutput('roster')
  #               )
  #             )
  #
  #   ),
  #   nav_panel(title = "Training Summary",
  #             navset_pill(
  #               nav_panel(title = "Individual",
  #                         layout_sidebar(
  #                           sidebar = sidebar(
  #                             title = "Set Filters",
  #                             selectInput("summary_firefighter", "Firefighter", Roster$full_name),
  #                             dateRangeInput('ind_training_filter_range',
  #                                            "Show trainings between:",
  #                                            start = as.Date(paste0(year(Sys.Date()), "-01-01")),
  #                                            end = as.Date(paste0(year(Sys.Date()), "-12-31"))),
  #                             downloadButton("download_ind", "Download Firefighter Training Summary")
  #                           ),
  #                           layout_columns(
  #                             value_box("EMS Hours", textOutput("ff_ems_hours")),
  #                             value_box("Fire Hours", textOutput("ff_fire_hours")),
  #                             value_box("Wildland Hours", textOutput("ff_wildland_hours")),
  #                           ),
  #                           card(
  #                             plotlyOutput("ff_hours_plot")
  #                           )
  #                         )
  #               ),
  #
  #               nav_panel(title = "Department",
  #                         layout_sidebar(
  #                           sidebar = sidebar(
  #                             title = "Set Filters",
  #                             dateRangeInput('dep_training_filter_range',
  #                                            "Show trainings between:",
  #                                            start = as.Date(paste0(year(Sys.Date()), "-01-01")),
  #                                            end = as.Date(paste0(year(Sys.Date()), "-12-31"))),
  #                             downloadButton("download_dep", "Download Department Training Summary")
  #                           ),
  #                           value_box("Total Training Hours", textOutput("dep_total_hours")),
  #                           layout_columns(
  #                             value_box("EMS Hours", textOutput("dep_ems_hours")),
  #                             value_box("Fire Hours", textOutput("dep_fire_hours")),
  #                             value_box("Wildland Hours", textOutput("dep_wildland_hours")),
  #                           ),
  #                           card(
  #                             plotlyOutput("dep_hours_plot")
  #                           )
  #                         )
  #               )
  #             )
  #   ),
    nav_spacer(),
    nav_menu(
      title = "Settings",
      align = "right",
      nav_item(actionButton(ns("sign_out"), "Sign Out"), align = "center"),
      nav_item(helpText("v0.1.1"), align = "center")
    )

  )
}

#' @export
server <- function(id) {
  moduleServer(id, function(input, output, session) {

    ##### Global Stuff #####
    # Use reactiveValues to maintain a local copy of the roster that is available at all times.
    # Update the local copy whenever the stored copy is updated.
    # MyReactives <- reactiveValues()
    # MyReactives$roster <- board %>% pin_read("roster") %>%
    #   dplyr::mutate(start_date = as.Date(start_date))
    # MyReactives$Training <- board %>% pin_read("trainings") %>%
    #   dplyr::mutate(date = as.Date(date))

    ns <- session$ns
    # Sign in/out capabilities
    observeEvent(input$sign_out, {
      showModal(modalDialog(
        textInput(ns("username"), "Username"),
        passwordInput(ns("password"), "Password"),
        title = "Sign in",
        footer = tagList(
          actionButton(ns("sign_in"), "Sign In")
        )
      ))
    }, ignoreNULL = FALSE)

    # Check password and username
    observeEvent(input$sign_in, {
      # browser()
      if(input$username == "CFD" && input$password == "1975") {
        removeModal()
      } else {
        stopApp()
      }
    })

    training$Server('training')


    # ###### Manage Roster ######
    # output$roster <- renderDT({
    #   # browser()
    #   Table_Data <- MyReactives$roster |>
    #     filter(active_status == TRUE) |>
    #     select(first_name, last_name, start_date)
    #
    #   Table_Data <- FixColNames(Table_Data)
    #
    #   data.table(Table_Data)
    # })
    #
    # observeEvent(input$add_firefighter, {
    #   showModal(modalDialog(
    #     textInput('add_first_name', 'First Name'),
    #     textInput('add_last_name', 'Last Name'),
    #     dateInput('ff_start_date', 'Start Date', value = Sys.Date()),
    #     title = "Add Firefighter",
    #     footer = tagList(
    #       actionButton("action_add_firefigher", "Add Firefighter")
    #     )
    #   ))
    # })
    #
    #
    # # Test if duplicate names can be added
    # # Test if white space if successuflly removed
    # observeEvent(input$action_add_firefigher, {
    #   # browser()
    #   removeModal()
    #   proposed_full_name <- paste(trimws(input$add_first_name), trimws(input$add_last_name))
    #
    #   roster <- MyReactives$roster
    #   if (proposed_full_name %in% paste(roster$first_name, roster$last_name)) {
    #     showModal(modalDialog("The name you tried to add already exists. Please add a unique name.",
    #                           title = "Add Firefighter Failed"))
    #   } else {
    #     showModal(modalDialog("Please wait...", title = "Processing Changes"))
    #     new_index <- nrow(MyReactives$roster) + 1
    #     MyReactives$roster <- dplyr::bind_rows(MyReactives$roster,
    #                                            data.frame(
    #                                              firefighter_id = new_index,
    #                                              first_name = trimws(input$add_first_name),
    #                                              last_name = trimws(input$add_last_name),
    #                                              start_date = input$ff_start_date,
    #                                              active_status = TRUE)
    #     )
    #     board %>% pin_write(MyReactives$roster, "roster")
    #     removeModal()
    #     showModal(modalDialog(paste(proposed_full_name, "has been successfully added."),
    #                           title = "Success!",
    #                           easyClose = TRUE))
    #   }
    #
    # })
    #
    # observeEvent(input$remove_firefighter, {
    #   roster <- MyReactives$roster
    #   active_roster <- roster |>
    #     filter(active_status == TRUE)
    #   full_names <- paste(active_roster$first_name, active_roster$last_name)
    #   showModal(modalDialog(selectInput('remove_full_name', 'Please select firefighter to remove.', full_names),
    #                         title = "Remove Firefighter",
    #                         footer = tagList(
    #                           actionButton("action_remove_firefigher", "Remove Firefighter")
    #                         )
    #   ))
    # })
    #
    # observeEvent(input$action_remove_firefigher, {
    #   removeModal()
    #
    #   roster <- MyReactives$roster
    #
    #   if (input$remove_full_name %in% paste(roster$first_name, roster$last_name)) {
    #     showModal(modalDialog("Please wait...", title = "Processing Changes"))
    #     local_first_name <- strsplit(input$remove_full_name, " ")[[1]][1]
    #     local_last_name <- strsplit(input$remove_full_name, " ")[[1]][2]
    #     # roster <- roster[!(roster$first_name == local_first_name & roster$last_name == local_last_name),]
    #     roster[roster$first_name == local_first_name & roster$last_name == local_last_name,]$active_status <- FALSE
    #     board %>% pin_write(roster, "roster", 'rds')
    #     MyReactives$roster <- roster
    #     removeModal()
    #     showModal(modalDialog(paste(input$remove_full_name, "has been successfully removed."),
    #                           title = "Success!",
    #                           easyClose = TRUE))
    #
    #   } else {
    #     showModal(modalDialog("Please contact Joseph Richey.",
    #                           title = "Error Code 1",
    #                           easyClose = TRUE))
    #   }
    #
    # })
    #
    # ##### Ind Training Summary ####
    # R_Training_Data <- reactive({
    #   Filtered_Trainings <- MyReactives$trainings |>
    #     filter(delete == FALSE &
    #              date > input$ind_training_filter_range[1] &
    #              date < input$ind_training_filter_range[2])
    #
    #   Filtered_Roster <- MyReactives$roster |>
    #     filter(active_status == TRUE) |>
    #     mutate(full_name = paste(first_name, last_name))
    #
    #   Attendance |>
    #     left_join(Filtered_Roster) |>
    #     left_join(Filtered_Trainings) |>
    #     filter(!is.na(delete) & !is.na(active_status))
    #
    # })
    #
    # output$ff_ems_hours <- renderText({
    #   Data <- R_Training_Data() |>
    #     filter(full_name == input$summary_firefighter) |>
    #     filter(training_type == "EMS")
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$ff_fire_hours <- renderText({
    #   Data <- R_Training_Data() |>
    #     filter(full_name == input$summary_firefighter) |>
    #     filter(training_type == "Fire")
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$ff_wildland_hours <- renderText({
    #   Data <- R_Training_Data() |>
    #     filter(full_name == input$summary_firefighter) |>
    #     filter(training_type == "Wildland")
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$ff_hours_plot <- renderPlotly({
    #
    #   # Assuming your dataframe has a "date" column
    #   R_Training_Data <- R_Training_Data() %>%
    #     mutate(Month = format(as.Date(date), "%Y-%m")) |>
    #     filter(full_name == input$summary_firefighter)
    #
    #   # Generate a complete set of months
    #   all_months <- expand.grid(training_type = unique(R_Training_Data$training_type),
    #                             Month = unique(R_Training_Data$Month),
    #                             stringsAsFactors = FALSE)
    #
    #   # Merge with the training data to fill in missing months with zeros
    #   plot_data <- merge(all_months, R_Training_Data, by = c("training_type", "Month"), all.x = TRUE) %>%
    #     mutate(training_length = ifelse(is.na(training_length), 0, training_length)) |>
    #     group_by(training_type, Month) %>%
    #     summarise(Total_Length = sum(training_length))
    #
    #   # Create the plot with specified colors, legend, and hover text
    #   plot <- plot_ly(plot_data, x = ~Month, y = ~Total_Length, color = ~training_type,
    #                   type = 'scatter', mode = 'lines', colors = c("blue", "red", "green"),
    #                   text = ~paste("Total Hours: ", Total_Length, " hours")) %>%
    #     layout(title = "Training Summary",
    #            xaxis = list(title = "Month"),
    #            yaxis = list(title = "Training Length (hours)", zeroline = FALSE),
    #            showlegend = TRUE)
    #
    #   plot
    # })
    #
    # # Individual Data Download
    # R_Ind_Data_Download <- reactive({
    #   R_Training_Data() |>
    #     filter(full_name == input$summary_firefighter) |>
    #     select(full_name, training_type, topic, training_length, description, date)
    # })
    #
    # # Download Handler
    # output$download_ind <- downloadHandler(
    #   filename = function() {
    #     paste0(input$summary_firefighter, "-training-data-", Sys.Date(), ".csv")
    #   },
    #   content = function(file) {
    #     write.csv(R_Ind_Data_Download(), file)
    #   }
    # )
    #
    # ##### Dep Training Summary ####
    # R_Dep_Training_Data <- reactive({
    #   Filtered_Trainings <- MyReactives$trainings |>
    #     filter(delete == FALSE &
    #              date > input$dep_training_filter_range[1] &
    #              date < input$dep_training_filter_range[2])
    #
    #   Filtered_Roster <- MyReactives$roster |>
    #     filter(active_status == TRUE) |>
    #     mutate(full_name = paste(first_name, last_name))
    #
    #   Attendance |>
    #     left_join(Filtered_Roster) |>
    #     left_join(Filtered_Trainings) |>
    #     filter(!is.na(delete) & !is.na(active_status))
    #
    # })
    #
    #
    # output$dep_ems_hours <- renderText({
    #   Data <- R_Dep_Training_Data() |>
    #     filter(training_type == "EMS")
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$dep_fire_hours <- renderText({
    #   Data <- R_Dep_Training_Data() |>
    #     filter(training_type == "Fire")
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$dep_wildland_hours <- renderText({
    #   Data <- R_Dep_Training_Data() |>
    #     filter(training_type == "Wildland")
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$dep_total_hours <- renderText({
    #   Data <- R_Dep_Training_Data()
    #
    #   paste(sum(Data$training_length))
    # })
    #
    # output$dep_hours_plot <- renderPlotly({
    #
    #   # Assuming your dataframe has a "date" column
    #   R_Training_Data <- R_Dep_Training_Data() %>%
    #     mutate(Month = format(as.Date(date), "%Y-%m"))
    #
    #   # Generate a complete set of months
    #   all_months <- expand.grid(training_type = unique(R_Training_Data$training_type),
    #                             Month = unique(R_Training_Data$Month),
    #                             stringsAsFactors = FALSE)
    #
    #   # Merge with the training data to fill in missing months with zeros
    #   plot_data <- merge(all_months, R_Training_Data, by = c("training_type", "Month"), all.x = TRUE) %>%
    #     mutate(training_length = ifelse(is.na(training_length), 0, training_length)) |>
    #     group_by(training_type, Month) %>%
    #     summarise(Total_Length = sum(training_length))
    #
    #   # Create the plot with specified colors, legend, and hover text
    #   plot <- plot_ly(plot_data, x = ~Month, y = ~Total_Length, color = ~training_type,
    #                   type = 'scatter', mode = 'lines', colors = c("blue", "red", "green"),
    #                   text = ~paste("Total Hours: ", Total_Length, " hours")) %>%
    #     layout(title = "Training Summary",
    #            xaxis = list(title = "Month"),
    #            yaxis = list(title = "Training Length (hours)", zeroline = FALSE),
    #            showlegend = TRUE)
    #
    #   plot
    # })
    #
    # # Individual Data Download
    # R_Dep_Data_Download <- reactive({
    #   R_Dep_Training_Data() |>
    #     select(full_name, training_type, topic, training_length, description, date)
    # })
    #
    # # Download Handler
    # output$download_dep <- downloadHandler(
    #   filename = function() {
    #     paste0("cfd-training-data-", Sys.Date(), ".csv")
    #   },
    #   content = function(file) {
    #     write.csv(R_Dep_Data_Download(), file)
    #   }
    # )

  })
}