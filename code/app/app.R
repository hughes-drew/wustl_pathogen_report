library(tidyverse)
library(shiny)
library(shinyWidgets)
library(ggiraph)
library(reactable)

#load helper functions and reference data
source("app_utils.R")

#define user interface
ui <- navbarPage(
  theme = shinythemes::shinytheme("flatly"),
  title = "WUSTL Pathogen Report",

  #tab 1: table
  tabPanel(

    title= "Table",

    tags$head( tags$style(type="text/css", "text {font-family: sans-serif}")),

    sidebarLayout(

      sidebarPanel(

        selectizeInput(
          "table_interval",
          "Interval",
          choices = c("Week", "Month", "Year"),
          selected = "Week"
        ),

        selectizeInput(
          "table_period",
          "Week",
          choices = week_list,
          selected = "2021-04-11"
        ),

        selectizeInput(
          "table_age",
          "Age Group",
          choices = age_list,
          selected = age_list,
          multiple = TRUE
        ),

        selectizeInput(
          "table_setting",
          "Clinical Setting",
          choices = setting_list,
          selected = c("ED", "Inpatient", "Outpatient"),
          multiple = TRUE
        ),

        selectizeInput(
          "table_pt_location",
          "Patient Location",
          choices = location_list,
          selected = location_list,
          multiple = TRUE
        ),

        selectizeInput(
          "table_test_location",
          "Test Location",
          choices = location_list,
          selected = location_list,
          multiple = TRUE
        ),

        width = 3
      ),

      mainPanel(
        reactableOutput("table")
      )
    ),

    headerPanel(""),
    headerPanel("")

  ),

  #tab 2: line graph 1 (or area plot)
  tabPanel(
    title= "Compare Pathogens",

    sidebarPanel(

      sliderTextInput(
        "lg1_dateRange",
        "Date Range",
        choices = date_list,
        selected = c(
          lubridate::ceiling_date(as.Date("2021-04-01"), unit = "halfyear") - 365,
          lubridate::ceiling_date(as.Date("2021-04-01"), unit = "halfyear")
        ),
        hide_min_max = TRUE,
        from_max = lubridate::floor_date(as.Date("2021-04-01"), unit = "halfyear")
      ),

      selectizeInput(
        "lg1_pathogen",
        "Pathogen",
        choices = as.vector(unlist(pathogen_list)),
        selected = c("COVID-19", "Influenza A", "RSV"),
        multiple = TRUE
      ),

      selectizeInput(
        "lg1_age",
        "Age Group",
        choices = c("Adult", "Pediatric"),
        selected = c("Adult", "Pediatric"),
        multiple = TRUE
      ),

      selectizeInput(
        "table_setting",
        "Clinical Setting",
        choices = setting_list,
        selected = c("ED", "Inpatient", "Outpatient"),
        multiple = TRUE
      ),

      selectizeInput(
        "table_pt_location",
        "Patient Location",
        choices = location_list,
        selected = location_list,
        multiple = TRUE
      ),

      selectizeInput(
        "table_test_location",
        "Test Location",
        choices = location_list,
        selected = location_list,
        multiple = TRUE
      ),

      radioGroupButtons(
        inputId = "lg1_type",
        label = "Plot Type",
        choices = c("Line Graph", "Area Plot"),
        selected = "Line Graph",
        status = "primary"
      ),

      radioGroupButtons(
        inputId = "lg1_value",
        label = "Y-axis",
        choices = c("Positives (n)", "Positivity (%)"),
        selected = "Positivity (%)",
        status = "primary"
      ),

      width = 3
    ),

    mainPanel(
      girafeOutput(
        "lg1_plot",
        height = "600px"
      )
    )
  ),

  #tab 3: line graph 2
  tabPanel(
    title= "Compare Seasons",

    sidebarPanel(

      selectizeInput(
        "lg2_season",
        "Season",
        choices = rev(season_list),
        selected = tail(season_list, 3),
        multiple = TRUE
      ),

      selectInput(
        "lg2_pathogen",
        "Pathogen",
        choices = as.vector(unlist(pathogen_list)),
        selected = c("Influenza A"),
        multiple = FALSE
      ),

      selectizeInput(
        "lg2_age",
        "Age Group",
        choices = c("Adult", "Pediatric"),
        selected = c("Adult", "Pediatric"),
        multiple = TRUE
      ),

      selectizeInput(
        "lg2_setting",
        "Clinical Setting",
        choices = setting_list,
        selected = c("ED", "Inpatient", "Outpatient"),
        multiple = TRUE
      ),

      selectizeInput(
        "lg2_pt_location",
        "Patient Location",
        choices = location_list,
        selected = location_list,
        multiple = TRUE
      ),

      selectizeInput(
        "lg2_test_location",
        "Test Location",
        choices = location_list,
        selected = location_list,
        multiple = TRUE
      ),

      radioGroupButtons(
        inputId = "lg2_value",
        label = "Y-axis",
        choices = c("Positives (n)", "Positivity (%)"),
        selected = "Positivity (%)",
        status = "primary"
      ),

      width = 3
    ),

    mainPanel(
      girafeOutput(
        "lg2_plot",
        height = "600px"
      )
    )
  )
)

#define reactive functions
server <- function(input, output, session) {

  #time period selection with reactive choices
  observe({
    updateSelectInput(
      session,
      "table_period",
      label =
        if (input$table_interval == "Week"){
          "Week"
        } else if (input$table_interval == "Month"){
          "Month"
        } else {
          "Year"
        }
      ,
      choices =
        if (input$table_interval == "Week"){
          week_list
        } else if (input$table_interval == "Month"){
          paste(
            lubridate::year(month_list),
            lubridate::month(month_list, label = TRUE)
          )
        } else {
          lubridate::year(month_list)
        }
      ,
      selected =
        if (input$table_interval == "Week"){
          "2021-04-11"
        } else if (input$table_interval == "Month"){
          paste(
            lubridate::year(tail(month_list, 1)),
            lubridate::month(tail(month_list, 1), label = TRUE)
          )
        } else {
          tail(lubridate::year(month_list), 1)
        }
    )
  })

  #get table start date from user input
  table_anchorDate <- reactive({
    #year
    if (!grepl(" |-", input$table_period)){
      lubridate::floor_date(
        lubridate::ymd(paste(input$table_period, "01 01")),
        unit = "year"
      )

    #month
    } else if (grepl(" ", input$table_period)){
      lubridate::floor_date(
        lubridate::ymd(paste(input$table_period, "01")),
        unit = "month"
      )

    #week
    } else {
      lubridate::floor_date(
        as.Date(input$table_period),
        unit = "week"
      )
    }
  })

  #get one year/month/week prior to table start date from user input (for calculating interval changes)
  table_startDate <- reactive({
    #year
    if (!grepl(" |-", input$table_period)){
      lubridate::floor_date(
        lubridate::ymd(paste(input$table_period, "01 01")),
      unit = "year"
      ) - lubridate::years(1)

    #month
    } else if (grepl(" ", input$table_period)){
      lubridate::floor_date(
        lubridate::ymd(paste(input$table_period, "01")),
        unit = "month"
      ) - months(1)

    #week
    } else {
      lubridate::floor_date(
        as.Date(input$table_period),
        unit = "week"
      ) - lubridate::weeks(1)
    }
  })

  #get table end date from user input
  table_endDate <- reactive({
    #year
    if (!grepl(" |-", input$table_period)){
      lubridate::ceiling_date(
        lubridate::ymd(paste(input$table_period, "01 01")),
      unit = "year"
      )

    #month
    } else if (grepl(" ", input$table_period)){
      lubridate::ceiling_date(
        lubridate::ymd(paste(input$table_period, "01")),
        unit = "month"
      )

    #week
    } else {
      lubridate::ceiling_date(
        as.Date(input$table_period),
        unit = "week"
      )
    }
  })

  #get line graph start date from user input
  lg1_startDate <- reactive({
    lubridate::floor_date(
      as.Date(input$lg1_dateRange[1]),
      unit = "week"
    )
  })

  #get line graph end date from user input
  lg1_endDate <- reactive({
    lubridate::floor_date(
      as.Date(input$lg1_dateRange[2]),
      unit = "week",
      week_start = getOption("lubridate.week.start", 6)
    )
  })

  #filter and summarize table data
  summary_table <- reactive({
    df %>%
      filter(
        week >= table_startDate() &
        week < table_endDate()
      ) %>%
      mutate(
        period = case_when(
          week >= table_anchorDate() ~ "t2",
          week ~ "t1"
        ) #split observations into period requested (t2) and preceeding/reference period (t1)
      ) %>%
      select(-week) %>%
      group_by(target, period, .drop = FALSE) %>%
      count(result) %>%
      unite("var", c(period, result)) %>%
      right_join(
        expand_grid(
          tibble(target = unlist(pathogen_list)),
          tibble(var = c("t1_positive", "t1_negative", "t2_positive", "t2_negative"))
        ),
        by = c("target", "var")
      ) %>%
      replace_na(list(n = 0)) %>%
      pivot_wider(
        names_from = var,
        values_from = n
      ) %>%
      rowwise() %>%
      mutate(
        target = factor(target, levels = unlist(pathogen_list)),
        t1_total = t1_positive + t1_negative,
        t1_positivity = t1_positive / t1_total,
        t2_total = t2_positive + t2_negative,
        t2_positivity = t2_positive / t2_total,
        delta_n = t2_total - t1_total, #period-over-period change (n)
        delta_p = t2_positivity - t1_positivity, #period-over-period change (proportion)
        fisher = fisher.test(
          matrix(
            c(t1_positive, t1_negative, t2_positive, t2_negative),
            nrow = 2
          )
        )$p.value #period-over-period change (Fisher exact p-value)
      ) %>%
      inner_join(
        tibble(
          group = names(unlist(pathogen_list)),
          target = unlist(pathogen_list)
        ) %>%
        mutate(
          group = gsub("[0-9]*", "", group),
          target = factor(target, levels = unlist(pathogen_list))
        ),
        by = "target"
      ) %>%
      arrange(target) %>%
      select(
        group,
        target,
        t2_positive,
        t2_total,
        t2_positivity,
        t1_positive,
        t1_total,
        delta_p,
        fisher
      )
  })

  #filter and summarize line graph 1 data (tab 2)
  summary_lg1 <- reactive({
    temp <- df %>%
       filter(
         week >= lg1_startDate() &
         week <= lg1_endDate() &
         target %in% input$lg1_pathogen
       ) %>%
      group_by(target, week) %>%
      count(result) %>%
      pivot_wider(
        names_from = result,
        values_from = n,
        values_fill = 0
      )

    if (input$lg1_value == "Positives (n)"){
      temp <- temp %>%
        mutate(
          value = positive,
          label = "Positives (n)\n"
        )
    } else {
      temp <- temp %>%
        mutate(
          value = 100 * positive / (positive + negative),
          label = "Positivity (%)\n"
        )
    }

    return(temp)
  })

  #filter and summarize line graph 2 data (tab 3)
  summary_lg2 <- reactive({
    temp <- season %>%
      filter(
        season %in% input$lg2_season &
        target %in% input$lg2_pathogen
      )

    if (input$lg2_value == "Positives (n)"){
      temp <- temp %>%
        mutate(
          value = positive,
          label = "Positives (n)\n"
        )
    } else {
      temp <- temp %>%
        mutate(
          value = 100 * positive / (positive + negative),
          label = "Positivity (%)\n"
        )
    }

    return(temp)
  })

  #generate table
  output$table <- renderReactable({
    reactable(
      summary_table(),

      #nest by pathogen group
      groupBy = "group",

      #format individual columns
      columns = list(
        group = colDef(
          name = "Group"
        ),
        target = colDef(
          name = "Pathogen",
          na = "–",
          width = 150,
          style = function(value){
            style = ifelse(value %in% bacteria_list, "italic", NA)
            list(fontStyle = style)
          }
        ),
        t2_positive = colDef(
          name = "Positives (n)",
          na = "–"
        ),
        t2_total = colDef(
          name = "Total (n)",
          na = "–"
        ),
        t2_positivity = colDef(
          name = "Positivity (%)",
          format = colFormat(percent = TRUE, digits = 1),
          na = "–"
        ),
        delta_p = colDef(
          name =
            if (input$table_interval == "Week"){
              "WoW Change (%)"
            } else if (input$table_interval == "Month"){
              "MoM Change (%)"
            } else {
              "YoY Change (%)"
            }
          ,
          cell = function(value){
            if(is.na(value)){
              "-"
            } else if (value > 0) {
              paste0(paste0("+", round(100 * value, 1)), "%")
            } else if (value == 0) {
              "+0.0%"
            } else {
              paste0(round(100 * value, 1), "%")
            }
          },
          style = function(value, index) {
            color <-
              if(summary_table()[index, "fisher"] < 0.05){
                if(value < -0.15){
                  scale[1]
                } else if(value < -0.10){
                 scale[2]
                } else if(value < -0.05){
                 scale[3]
                } else if(value < 0){
                 scale[4]
                } else if(value > 0.15){
                 scale[9]
                } else if(value > 0.10){
                 scale[8]
                } else if(value > 0.05){
                 scale[7]
                } else if(value > 0){
                 scale[6]
                }
              } else {
               NA
            }
            list(background = color)
          },
          na = "–"
        ), #define cell color binned magnitude of difference (only use if p-value below threshold)
        t1_positive = colDef(
          show = FALSE
        ),
        t1_total = colDef(
          show = FALSE
        ),
        fisher = colDef(
          show = FALSE
        )
      ),

      #other table options
      sortable = FALSE,
      defaultExpanded = TRUE,
      pagination = FALSE,
      highlight = TRUE,
      striped = TRUE,
      compact = TRUE,
      defaultPageSize = 20,
      wrap = FALSE
    )
  })

  #generate line graph 1 or area plot
  output$lg1_plot <- renderGirafe({

    #line graph 1
    if (input$lg1_type == "Line Graph"){
      #main plot
      p <- summary_lg1() %>%
        ggplot(aes(week, value, color = target)) +
          geom_point_interactive(aes(tooltip = round(value, 1), data_id = value), size = 2.5) +
          geom_line_interactive(aes(tooltip = target, data_id = target)) +
          theme_minimal() +
          theme(
            axis.text = element_text(size = 10),
            axis.title = element_text(size = 12),
            legend.text = element_text(size = 10)
          ) +
          scale_color_discrete(name = "") +
          scale_shape_discrete(name = "") +
          xlab("") +
          ylab(unique(summary_lg1()["label"]))

      #interactivity and size
      girafe(
        ggobj = p,
        options = list(
          opts_selection(type = "single"),
          opts_hover(css = "stroke-width:1.5pt;")
        ),
        opts_sizing(rescale = FALSE),
        width_svg = 7.5,
        height_svg = 6
      )

    #area plot
    } else if (input$lg1_type == "Area Plot"){
      #main plot
      p <- summary_lg1() %>%
        ggplot(aes(week, value, fill = target)) +
          geom_area_interactive(aes(tooltip = target, data_id = target)) +
          theme_minimal() +
          theme(
            axis.text = element_text(size = 10),
            axis.title = element_text(size = 12),
            legend.text = element_text(size = 10)
          ) +
          scale_fill_discrete(name = "") +
          xlab("") +
          ylab(unique(summary_lg1()["label"]))

      #interactivity and size
      girafe(
        ggobj = p,
        options = list(
          opts_selection(type = "single"),
          opts_hover_inv(css = "opacity:0.5;"),
          opts_hover(css = "opacity:1;")
        ),
        opts_sizing(rescale = FALSE),
        width_svg = 7.5,
        height_svg = 6
      )
    }
  })

  #generate line graph 2
  output$lg2_plot <- renderGirafe({
    #main plot
    p <- summary_lg2() %>%
      ggplot(aes(week_int, value, color = as.factor(season))) +
        geom_point_interactive(aes(tooltip = round(value, 1), data_id = value), size = 2.5) +
        geom_line_interactive(aes(tooltip = season, data_id = season)) +
        theme_minimal() +
        theme(
          axis.text = element_text(size = 10),
          axis.title = element_text(size = 12),
          legend.text = element_text(size = 10)
        ) +
        scale_color_discrete(name = "") +
        scale_shape_discrete(name = "") +
        scale_x_continuous(
          breaks = c(0, 13, 26, 39, 52),
          labels = c("Jul", "Oct", "Jan", "Apr", "Jul")
        ) +
        xlab("") +
        ylab(unique(summary_lg2()["label"]))

    #interactivity and size
    girafe(
      ggobj = p,
      options = list(
        opts_selection(type = "single"),
        opts_hover(css = "stroke-width:1.5pt;")
      ),
      opts_sizing(rescale = FALSE),
      width_svg = 8.25,
      height_svg = 6
    )
  })
}

#run app
shinyApp(ui, server)
