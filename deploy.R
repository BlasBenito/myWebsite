blogdown::install_hugo()

# blogdown::new_site(dir = "Theme", theme = "gcushen/hugo-academic")

blogdown::build_site()

blogdown::serve_site()
blogdown::stop_server()

#create new post
blogdown::new_post(title = "post_title", ext = '.Rmarkdown', subdir = "post")
