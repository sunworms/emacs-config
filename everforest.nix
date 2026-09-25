{
  melpaBuild,
  inputs,
}:
melpaBuild {
  pname = "everforest";
  version = "0.0.1";
  src = inputs.everforest.src;
}
