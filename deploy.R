blogdown::install_hugo()

blogdown::new_site(dir = "Theme", theme = "gcushen/hugo-academic")

blogdown::build_site()

blogdown::serve_site()
