import massive.munit.TestSuite;

import saturn.DNATest;
import saturn.WebServiceTest;
import sgc.MathUtilsTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(saturn.DNATest);
		add(saturn.WebServiceTest);
		add(sgc.MathUtilsTest);
	}
}
