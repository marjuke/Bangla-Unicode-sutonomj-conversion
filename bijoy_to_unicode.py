import converter
import util


class BijoyToUnicode:
    def convertBijoyToUnicode(self, srcString):
        if not srcString:
            return srcString

        # Normalize common input mistakes before conversion.
        srcString = util.doCharMap(srcString, converter.preConversionMap)

        # Core Bijoy -> Unicode mapping.
        srcString = util.doCharMap(srcString, converter.conversionMap)

        # Cleanup any duplicate halants.
        srcString = util.doCharMap(srcString, converter.proConversionMap)

        # Reorder to proper Unicode sequence.
        srcString = converter.Unicode().reArrangeUnicodeConvertedText(srcString)

        # Final post-processing fixes.
        srcString = util.doCharMap(srcString, converter.postConversionMap)

        return srcString
