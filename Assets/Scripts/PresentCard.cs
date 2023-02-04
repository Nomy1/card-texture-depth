using UnityEngine;

public class PresentCard : MonoBehaviour
{
    [SerializeField, Range(0f, 10f)] float playSpeed;
    [SerializeField, Range(0f, 40f)] float rotationHorizontalRange;
    [SerializeField, Range(0f, 40f)] float rotationVerticalRange;
    
    void Update()
    {
        float horizontalRotation = Mathf.Sin(Time.time * playSpeed) * rotationHorizontalRange;
        float verticalRotation = Mathf.Cos(Time.time * playSpeed) * rotationVerticalRange;
        
        transform.localRotation = 
            Quaternion.AngleAxis(horizontalRotation, transform.up) *
            Quaternion.AngleAxis(verticalRotation, transform.right);
    }
}
