BEGIN {print "1..22\n";}
END {print "not ok 1\n" unless $loaded;}
use XML::DOM;
use CheckAncestors;
use CmpDOM;
$loaded = 1;
print "ok 1\n";

my $test = 1;
sub assert_ok
{
    my $ok = shift;
    print "not " unless $ok;
    ++$test;
    print "ok $test\n";
    $ok;
}

#Test 2

my $str = <<END;
<!DOCTYPE simpsons [
 <!ELEMENT person (#PCDATA)>
 <!ATTLIST person
  name CDATA #REQUIRED
  hair (none | blue | yellow) "yellow"
  sex CDATA #REQUIRED>
]>
<simpsons>
 <person name="homer" hair="none" sex="male"/>
 <person name="marge" hair="blue" sex="female"/>
 <person name="bart" sex="almost"/>
 <person name="lisa" sex="never"/>
</simpsons>
END

my $parser = new XML::DOM::Parser;
my $doc = $parser->parse ($str);
assert_ok (not $@);

my $out = $doc->toString;
assert_ok ($out eq $str);

my $root = $doc->getDocumentElement;
my $bart = $root->getElementsByTagName("person")->item(2);
assert_ok (defined $bart);

my $lisa = $root->getElementsByTagName("person")->item(3);
assert_ok (defined $lisa);

my $battr = $bart->getAttributes;
assert_ok ($battr->getLength == 3);

my $lattr = $lisa->getAttributes;
assert_ok ($battr->getLength == 3);

my $hair = $battr->getNamedItem ("hair");
assert_ok ($hair->getValue eq "yellow");
assert_ok (not $hair->isSpecified);

my $hair2 = $bart->removeAttributeNode ($hair);
# we're not returning default attribute nodes
assert_ok (not defined $hair2);

# check if hair is still defaulted
$hair2 = $battr->getNamedItem ("hair");
assert_ok ($hair2->getValue eq "yellow");
assert_ok (not $hair2->isSpecified);

# replace default hair with pointy hair
$battr->setNamedItem ($doc->createAttribute ("hair", "pointy"));
assert_ok ($bart->getAttribute("hair") eq "pointy");

$hair2 = $battr->getNamedItem ("hair");
assert_ok ($hair2->isSpecified);

# exception - can't share Attr nodes
eval {
    $lisa->setAttributeNode ($hair2);
};
assert_ok ($@);

# add it again - it replaces itself
$bart->setAttributeNode ($hair2);
assert_ok ($battr->getLength == 3);

# (cloned) hair transplant from bart to lisa
$lisa->setAttributeNode ($hair2->cloneNode);
$hair = $lattr->getNamedItem ("hair");
assert_ok ($hair->isSpecified);
assert_ok ($hair->getValue eq "pointy");

my $doc2 = $doc->cloneNode(1);
my $cmp = new CmpDOM;
unless (assert_ok ($doc->equals ($doc2, $cmp)))
{
    # This shouldn't happen
    print "Context: ", $cmp->context, "\n";
}

assert_ok ($hair->getNodeTypeName eq "ATTRIBUTE_NODE");

$bart->removeAttribute ("hair");

# check if hair is still defaulted
$hair2 = $battr->getNamedItem ("hair");
assert_ok ($hair2->getValue eq "yellow");
assert_ok (not $hair2->isSpecified);