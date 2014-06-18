# Adding Extra Output Formats to Yaks

Individual output formats are each handled by a dedicated `Yaks::Serializer` class. These take a `Yaks::Resource` as input, and turn it into the requested output format.

A `Yaks::Resource` is created by "mapping" domain models by a `Yaks::Mapper`. In a `Yaks::Mapper` subclass a DSL is available to specify how to extract different types of information, for example attributes or links, and store them in a generalized way in a `Resource`.

Different formats have different features. Simple formats might just represent attributes, links, and subresources, other formats have queries, forms, or RDF identifiers. If a format represents data of a different nature, then the first step is to decide on a good and straightforward syntax to specify how to derive this data. This can then be stored in a `Yaks::Resource`, and formats that support it can use it, other formats can ignore it.

This is already the case, JSON-API ignores links for example.

So adding an output format is generally straightforward, as long as the information that the output format supports is already available in `Yaks::Resource`. In that case adding a `Yaks::Serializer::YourFormat` is all that is needed.

If the format has features that are not yet available then syntax needs to be added for those features. The guiding idea there is to try and find more than one format with the given feature, to make sure the intermediate abstraction is general and not tied to the specifics and vocabulary of a single format.
