#/usr/bin/perl

# this would be welcome as a first step, to make the .xml file easier to work with

# usage: perl simplify.pl <blog.xml> > <simplified.xml>
while(<>) {
    s/<entry>/\n<entry>/g;
    print;
}
