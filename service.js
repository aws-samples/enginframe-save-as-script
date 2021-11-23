jQuery(document).ready(function () {

    // changes service action button label "Submit" with "Save script" if 
    // Save as script checkbox is selected. Reverts if unselected

    function updateSubmitButton() {
        if (jQuery('.save-as-script').is(':checked'))  {
            jQuery('#serviceaction_submit').val('Save script');
        } else {
            jQuery('#serviceaction_submit').val('Submit');
        }
    }

    jQuery('.save-as-script').change(function() {
        updateSubmitButton(); 
    })
    
});