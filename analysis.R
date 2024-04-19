## Library loading ## ----

library(ggplot2)
library(dplyr)

individual <- readr::read_csv(
  here::here('data', 
             'individual.csv')
) %>%
  select(stem_diameter, height, growth_form)

## Subset data analysis ## ----

analysis_df <- individual %>%
  filter(complete.cases(.),
         growth_form != 'liana')

## Order growth form level ## ----

gf_levels <- table(analysis_df$growth_form) %>%
  sort() %>%
  names()

analysis_df <- analysis_df %>%
  mutate(growth_form = factor(growth_form, levels = gf_levels))

analysis_df %>%
  ggplot(aes(x = log(height), y = log(stem_diameter))) +
  geom_point(alpha = 0.2) +
  geom_smooth(method = 'lm')+
  xlab('Log of height (m') +
  ylab('Log of stem diameter (cm') +
  theme_bw()

## Fit linear model with a growth form interaction ## ----

lm_overall <-  lm(log(stem_diameter) ~ log(height) * growth_form,
                 data = analysis_df)

analysis_df %>%
  ggplot(aes(x = log(height), 
             y = log(stem_diameter),
             colour = growth_form)) +
  geom_point(alpha = 0.1) +
  geom_smooth(method = 'lm')+
  labs(
       x = 'Log of height (m)',
       y = 'Log of stem diameter (cm)',
       colour = 'Growth Form'
       ) +
  theme_bw()

