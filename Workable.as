package
{   
    public interface Workable
    {
        function needsWork():Boolean;
        
        function work(citizen:Citizen):void;
    }
}