connection(:default) do
  {
    url: "redis://localhost"
  }
end

connection(:pooled) do
  {
    url: "redis://localhost/2",
    pool_timeout: 5,
    pool_size: 5
  }
end
